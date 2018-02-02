import std.algorithm : filter, map;
import std.exception : enforce;
import std.file : readText;
import std.stdio : write;

import adl_validator;

int main(string[] args)
{
    if (args.length >= 2 && args[1] == "--version")
    {
        write("0.0.1");
        return 0;
    }

    enforce(args.length >= 3);

    immutable adlSearchContent = readText(args[1]);
    auto searchData = xmlToSearchData(adlSearchContent)
        .filter!(e => e.isActive)
        .map!(Search.create);

    auto pathInfos = getPathInfos(args[2]);

    return pathInfos.validateAdl(searchData) ? 0 : 1;
}
