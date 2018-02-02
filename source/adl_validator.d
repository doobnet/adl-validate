module adl_validator;

import std.stdio;

import std.format : format;
import std.file : dirEntries, SpanMode;
import std.xml : DocumentParser, Element;
import std.stdio : writeln;
import std.array;
import std.algorithm;
import std.conv : to;
import std.range : isInputRange, ElementType, only, chain;

struct describe
{
    string description;
}

alias context = describe;

struct it
{
    string description;
}

enum SizeType
{
    bytes,
    kibibytes,
    mebibyte
}

struct SearchData
{
    string searchString;
    string sourceType;
    string destDirectory;
    string adlsComment;
    bool isActive;
    long maxSize;
    long minSize;
    SizeType sizeType;
    bool isAutoQueue;
}

struct PathInfo
{
    immutable string path;
    immutable long size;

    pure bool isValidSize(const ref SearchData data) const
    {
        return !(size >= data.minSize && size <= data.maxSize);
    }

    @describe("isValidSize") version(unittest)
    {
        static immutable SearchData data = { maxSize: 10, minSize: -1 };

        @context("when the size is larger than the maximum size")
        {
            @it("returns true") unittest
            {
                assert(PathInfo(null, 11).isValidSize(data));
            }
        }

        @context("when the size is smaller than the maximum size")
        {
            @it("returns false") unittest
            {
                assert(!PathInfo(null, 9).isValidSize(data));
            }
        }

        @context("when the size is the same as the maximum size")
        {
            @it("returns false") unittest
            {
                assert(!PathInfo(null, 10).isValidSize(data));
            }
        }

        @context("when the size is less than the minimum size")
        {
            @it("returns true") unittest
            {
                SearchData data = { maxSize: 10, minSize: 2 };
                assert(PathInfo(null, 1).isValidSize(data));
            }
        }

        @context("when the size is the same as the minimum size")
        {
            @it("returns false") unittest
            {
                SearchData data = { maxSize: 10, minSize: 1 };
                assert(!PathInfo(null, 1).isValidSize(data));
            }
        }

        @context("when the specified size is in KiB")
        {
            @("and the size larger than the maximum size")
            {
                @it("returns true") unittest
                {
                    immutable SearchData data = {
                        maxSize: 10,
                        minSize: -1,
                        sizeType: SizeType.kibibytes
                    };

                    assert(PathInfo(null, 11 * 1000).isValidSize(data));
                }
            }
        }
    }
}

struct SearchValidation
{
    bool isValid;
    string path;
    string reason;

    pure bool opCast() const
    {
        return isValid;
    }
}

abstract class Search
{
    immutable SearchData data;

    pure this(SearchData data)
    {
        this.data = data;
    }

    pure static Search create(SearchData data)
    {
        switch(data.sourceType)
        {
            case "Filename": return new FilenameSearch(data);
            case "Full Path": return new FullPathSearch(data);
            case "Directory": return new DirectorySearch(data);
            default: throw new SourceTypeException(data.sourceType);
        }
    }

    unittest
    {
        SearchData data = { sourceType: "Filename" };
        auto search = Search.create(data);

        assert((cast(FilenameSearch) search) !is null);
    }

    unittest
    {
        SearchData data = { sourceType: "Full Path" };
        auto search = Search.create(data);

        assert((cast(FullPathSearch) search) !is null);
    }

    SearchValidation isValid(PathInfo pathInfo) const
    {
        return SearchValidation(pathInfo.isValidSize(data));
    }
}

final class FilenameSearch : Search
{
    pure this(SearchData data)
    {
        super(data);
    }

    override SearchValidation isValid(PathInfo pathInfo) const
    {
        import std.path : baseName;

        if (super.isValid(pathInfo))
            return SearchValidation(true, pathInfo.path, data.destDirectory);
        else
        {
            immutable filename = pathInfo.path.baseName;
            const match = filename.isMatch(data.searchString);
            return SearchValidation(!match, pathInfo.path, data.destDirectory);
        }
    }

    @describe("isValid") version(unittest)
    {
        static immutable(SearchData) getData(string searchString = `foo\.txt`) pure
        {
            SearchData data = {
                searchString: searchString,
                maxSize: 10,
                minSize: -1
            };

            return data;
        }

        @context("when the path pattern is matching")
        {
            @context("and the size of the file is within the search")
            {
                @it("the file is not valid") unittest
                {
                    immutable data = getData;
                    immutable search = new immutable FilenameSearch(data);
                    immutable pathInfo = PathInfo("foo.txt", data.maxSize - 1);
                    assert(!search.isValid(pathInfo));
                }
            }

            @context("and the size of the file is larger than the search")
            {
                @it("the file is valid") unittest
                {
                    immutable data = getData;
                    immutable search = new immutable FilenameSearch(data);
                    immutable pathInfo = PathInfo("foo.txt", data.maxSize + 1);
                    assert(search.isValid(pathInfo));
                }
            }

            @context("and the size of the file is smaller than the search")
            {
                @it("the file is valid") unittest
                {
                    immutable SearchData data = {
                        searchString: "(?:^.)",
                        maxSize: 10,
                        minSize: 2
                    };

                    immutable search = new immutable FilenameSearch(data);
                    immutable pathInfo = PathInfo("foo.txt", data.minSize - 1);
                    assert(search.isValid(pathInfo));
                }
            }
        }

        @context("when the path pattern is not matching")
        {
            @it("the file is valid") unittest
            {
                immutable data = getData("bar.txt");
                immutable search = new immutable FilenameSearch(data);
                immutable pathInfo = PathInfo("foo.txt", data.maxSize - 1);
                assert(search.isValid(pathInfo));
            }
        }
    }
}

final class FullPathSearch : Search
{
    pure this(SearchData data)
    {
        super(data);
    }

    override SearchValidation isValid(PathInfo pathInfo) const
    {
        if (super.isValid(pathInfo))
            return SearchValidation(true, pathInfo.path, data.destDirectory);
        else
        {
            const match = pathInfo.path.isMatch(data.searchString);
            return SearchValidation(!match, pathInfo.path, data.destDirectory);
        }
    }

    @describe("isValid") version(unittest)
    {
        static immutable(SearchData) getData(string searchString = "(?:^.)") pure
        {
            SearchData data = {
                searchString: searchString,
                maxSize: 10,
                minSize: -1
            };

            return data;
        }

        @context("when the path pattern is matching")
        {
            @context("and the size of the file is within the search")
            {
                @it("the file is not valid") unittest
                {
                    immutable data = getData;
                    immutable search = new immutable FullPathSearch(data);
                    immutable pathInfo = PathInfo("foo.txt", data.maxSize - 1);
                    assert(!search.isValid(pathInfo));
                }
            }

            @context("and the size of the file is larger than the search")
            {
                @it("the file is valid") unittest
                {
                    immutable data = getData;
                    immutable search = new immutable FullPathSearch(data);
                    immutable pathInfo = PathInfo("foo.txt", data.maxSize + 1);
                    assert(search.isValid(pathInfo));
                }
            }

            @context("and the size of the file is smaller than the search")
            {
                @it("the file is valid") unittest
                {
                    immutable SearchData data = {
                        searchString: "(?:^.)",
                        maxSize: 10,
                        minSize: 2
                    };

                    immutable search = new immutable FullPathSearch(data);
                    immutable pathInfo = PathInfo("foo.txt", data.minSize - 1);
                    assert(search.isValid(pathInfo));
                }
            }
        }

        @context("when the path pattern is not matching")
        {
            @it("the file is valid") unittest
            {
                immutable data = getData("bar.txt");
                immutable search = new immutable FullPathSearch(data);
                immutable pathInfo = PathInfo("foo.txt", data.maxSize - 1);
                assert(search.isValid(pathInfo));
            }
        }
    }
}

final class DirectorySearch : Search
{
    pure this(SearchData data)
    {
        super(data);
    }

    override SearchValidation isValid(PathInfo pathInfo) const
    {
        import std.path : dirName;

        if (super.isValid(pathInfo))
            return SearchValidation(true, pathInfo.path, data.destDirectory);
        else
        {
            immutable directory = pathInfo.path.dirName;
            const match = directory.isMatch(data.searchString);
            return SearchValidation(!match, directory, data.destDirectory);
        }
    }

    @describe("isValid") version(unittest)
    {
        static immutable(SearchData) getData(string searchString = "bar") pure
        {
            SearchData data = {
                searchString: searchString,
                maxSize: 10,
                minSize: -1
            };

            return data;
        }

        @context("when the path pattern is matching")
        {
            @context("and the size of the file is within the search")
            {
                @it("the file is not valid") unittest
                {
                    immutable data = getData;
                    immutable search = new immutable DirectorySearch(data);
                    immutable pathInfo = PathInfo("bar/foo.txt", data.maxSize - 1);
                    assert(!search.isValid(pathInfo));
                }
            }

            @context("and the size of the file is larger than the search")
            {
                @it("the file is valid") unittest
                {
                    immutable data = getData;
                    immutable search = new immutable DirectorySearch(data);
                    immutable pathInfo = PathInfo("bar/foo.txt", data.maxSize + 1);
                    assert(search.isValid(pathInfo));
                }
            }

            @context("and the size of the file is smaller than the search")
            {
                @it("the file is valid") unittest
                {
                    immutable SearchData data = {
                        searchString: "bar",
                        maxSize: 10,
                        minSize: 2
                    };

                    immutable search = new immutable DirectorySearch(data);
                    immutable pathInfo = PathInfo("bar/foo.txt", data.minSize - 1);
                    assert(search.isValid(pathInfo));
                }
            }
        }

        @context("when the path pattern is not matching")
        {
            @it("the file is valid") unittest
            {
                immutable data = getData("foo");
                immutable search = new immutable DirectorySearch(data);
                immutable pathInfo = PathInfo("bar/foo.txt", data.maxSize - 1);
                assert(search.isValid(pathInfo));
            }
        }
    }
}

final class SizeTypeException : Exception
{
    immutable string sizeType;

    pure this(string sizeType, string file = __FILE__, size_t line = __LINE__)
    {
        this.sizeType = sizeType;
        super(format(`Unhandled size type "%s"`, sizeType), file, line);
    }
}

final class SourceTypeException : Exception
{
    immutable string sourceType;

    pure this(string sourceType, string file = __FILE__, size_t line = __LINE__)
    {
        this.sourceType = sourceType;
        super(format(`Unrecognized source type "%s"`, sourceType), file, line);
    }
}

SearchData[] xmlToSearchData(string xml)
{
    SearchData[] datas;
    auto parser = new DocumentParser(xml);

    parser.onStartTag["Search"] = (parser) {
        SearchData data;

        with (data)
        {
            parser.onEndTag["SearchString"] = (in e) { searchString = e.toNative; };
            parser.onEndTag["SourceType"] = (in e) { sourceType = e.toNative; };
            parser.onEndTag["DestDirectory"] = (in e) { destDirectory = e.toNative; };
            parser.onEndTag["AdlsComment"] = (in e) { adlsComment = e.text; };
            parser.onEndTag["IsActive"] = (in e) { isActive = e.toNative!bool; };
            parser.onEndTag["MaxSize"] = (in e) { maxSize = e.toNative!long; };
            parser.onEndTag["MinSize"] = (in e) { minSize = e.toNative!long; };
            parser.onEndTag["SizeType"] = (in e) { sizeType = e.toNative!SizeType; };
            parser.onEndTag["IsAutoQueue"] = (in e) { isAutoQueue = e.toNative!bool; };
        }

        parser.parse();
        data.maxSize = data.maxSize.toBytes(data.sizeType);
        data.minSize = data.minSize.toBytes(data.sizeType);

        datas ~= data;
    };

    parser.parse();

    return datas;
}

unittest
{
    immutable SearchData data1 = {
        searchString: "search string 1",
        sourceType: "source type 1",
        destDirectory: "dest directory 1",
        adlsComment: "adls comment 1",
        isActive: true,
        maxSize: -1,
        minSize: -1,
        sizeType: SizeType.bytes,
        isAutoQueue: false,
    };

    immutable SearchData data2 = {
        searchString: "search string 2",
        sourceType: "source type 2",
        destDirectory: "dest directory 2",
        adlsComment: "",
        isActive: false,
        maxSize: 2,
        minSize: 2,
        sizeType: SizeType.bytes,
        isAutoQueue: true,
    };

    enum xml = q"XML
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<ADLSearch>
  <SearchGroup>
    <Search>
      <SearchString RegEx="0">%s</SearchString>
      <SourceType>%s</SourceType>
      <DestDirectory>%s</DestDirectory>
      <AdlsComment>%s</AdlsComment>
      <IsActive>%s</IsActive>
      <MaxSize>%s</MaxSize>
      <MinSize>%s</MinSize>
      <SizeType>%s</SizeType>
      <IsAutoQueue>%s</IsAutoQueue>
    </Search>
    <Search>
      <SearchString RegEx="1">%s</SearchString>
      <SourceType>%s</SourceType>
      <DestDirectory>%s</DestDirectory>
      <AdlsComment/>
      <IsActive>%s</IsActive>
      <MaxSize>%s</MaxSize>
      <MinSize>%s</MinSize>
      <SizeType>%s</SizeType>
      <IsAutoQueue>%s</IsAutoQueue>
    </Search>
  </SearchGroup>
</ADLSearch>
XML".format(
    data1.searchString,
    data1.sourceType,
    data1.destDirectory,
    data1.adlsComment,
    data1.isActive ? "1" : "0",
    data1.maxSize,
    data1.minSize,
    "B",
    data1.isAutoQueue ? "1" : "0",

    data2.searchString,
    data2.sourceType,
    data2.destDirectory,
    data2.isActive ? "1" : "0",
    data2.maxSize,
    data2.minSize,
    "B",
    data2.isAutoQueue ? "1" : "0"
);

    assert(xmlToSearchData(xml) == [data1, data2]);
}

auto getPathInfos(string path)
{
    return dirEntries(path, SpanMode.depth)
        .map!(e => PathInfo(e.name, e.size));
}

bool validateAdl(PathInfoRange, SearchRange)(PathInfoRange pathInfos, SearchRange searches)
    if (isInputRange!PathInfoRange && is(ElementType!PathInfoRange == PathInfo) &&
        isInputRange!SearchRange && is(ElementType!SearchRange == Search))
{
    auto invalid = pathInfos.map!(
        p => searches.map!(s => s.isValid(p))
    ).joiner
     .filter!(e => !e.isValid)
     .array
     .sort!((a, b) => a.reason < b.reason)
     .chunkBy!((a, b) => a.reason == b.reason);

    if (invalid.empty)
        return true;

    invalid.map!(
        vals => chain(
            vals.front.reason, "\n", vals.map!(e => e.path).joiner("\n")
        )
    ).joiner("\n\n").write;

    return false;
}

T toNative(T = string)(in Element e)
{
    static if (is(T == string))
        return e.text;
    else static if (is(T == bool))
        return e.text == "1";
    else static if (is(T == int))
        return e.text.to!int;
    else static if (is(T == long))
        return e.text.to!long;
    else static if (is(T == SizeType))
    {
        auto text = e.text;

        switch (text)
        {
            case "B": return SizeType.bytes;
            case "KiB": return SizeType.kibibytes;
            case "MiB": return SizeType.mebibyte;
            default:
                throw new SizeTypeException(text);
        }
    }

    else
        static assert(false, "Unhandled type '" ~ T.stringof ~ "'");
}

unittest
{
    import std.exception;

    Element element(string text)
    {
        return new Element("dummy", text);
    }

    assert(element("foo").toNative == "foo");
    assert(element("foo").toNative!string == "foo");

    assert(element("2").toNative!int == 2);
    assert(element("-1").toNative!int == -1);

    assert(element("1").toNative!bool == true);
    assert(element("0").toNative!bool == false);

    assert(element("B").toNative!SizeType == SizeType.bytes);
    assertThrown!SizeTypeException(element("C").toNative!SizeType);

    assert(__traits(compiles, element("foo").toNative!byte) == false);
}

long toBytes(long value, SizeType sizeType) pure nothrow
{
    with (SizeType)
        final switch (sizeType)
        {
            case bytes: return value;
            case kibibytes: return value * 1024;
            case mebibyte: return value * 1024 * 1024;
        }
}

bool isMatch(string str, string pattern)
{
    import oniguruma;

    static void error(T...)(int result, T t)
    {
        char[ONIG_MAX_ERROR_MESSAGE_LEN] s;
        auto length = onig_error_code_to_str(s.ptr, result, t);
        throw new Exception(s[0 .. length].idup);
    }

    auto encodings = [ONIG_ENCODING_UTF8];
    onig_initialize(encodings.ptr, cast(int) encodings.length);
    scope (exit) onig_end();

    regex_t* reg;
    OnigErrorInfo einfo;
    auto result = onig_new(&reg, pattern.ptr, pattern.ptr + pattern.length, ONIG_OPTION_DEFAULT, ONIG_ENCODING_UTF8, ONIG_SYNTAX_DEFAULT, &einfo);
    scope (exit) onig_free(reg);

    if (result != ONIG_NORMAL)
        error(result, &einfo);

    auto region = onig_region_new();
    scope (exit) onig_region_free(region, 1);

    auto end = str.ptr + str.length;
    auto start = str.ptr;
    auto range = end;
    result = onig_search(reg, str.ptr, end, start, range, region, ONIG_OPTION_NONE);

    if (result >= 0)
        return true;

    else if (result == ONIG_MISMATCH)
        return false;

    else
        error(result);

    assert(0);
}
