module oniguruma;

import core.stdc.config;

extern (C):

/**********************************************************************
  oniguruma.h - Oniguruma (regular expression library)
**********************************************************************/
/*-
 * Copyright (c) 2002-2018  K.Kosako  <sndgk393 AT ybb DOT ne DOT jp>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

enum ONIGURUMA_VERSION_MAJOR = 6;
enum ONIGURUMA_VERSION_MINOR = 7;
enum ONIGURUMA_VERSION_TEENY = 1;

/* escape Mac OS X/Xcode 2.4/gcc 4.0.1 problem */

enum HAVE_STDARG_PROTOTYPES = 1;

extern (D) auto P_(T)(auto ref T args)
{
    return args;
}

extern (D) auto PV_(T)(auto ref T args)
{
    return args;
}

/* PART: character encoding */

alias UChar = OnigUChar;

alias OnigCodePoint = uint;
alias OnigUChar = char;
alias OnigCtype = uint;
alias OnigLen = uint;

enum ONIG_INFINITE_DISTANCE = ~(cast(OnigLen) 0);

alias OnigCaseFoldType = uint; /* case fold flag */

extern __gshared OnigCaseFoldType OnigDefaultCaseFoldFlag;

/* #define ONIGENC_CASE_FOLD_HIRAGANA_KATAKANA  (1<<1) */
/* #define ONIGENC_CASE_FOLD_KATAKANA_WIDTH     (1<<2) */
enum ONIGENC_CASE_FOLD_TURKISH_AZERI = 1 << 20;
enum INTERNAL_ONIGENC_CASE_FOLD_MULTI_CHAR = 1 << 30;

enum ONIGENC_CASE_FOLD_MIN = INTERNAL_ONIGENC_CASE_FOLD_MULTI_CHAR;
alias ONIGENC_CASE_FOLD_DEFAULT = OnigDefaultCaseFoldFlag;

enum ONIGENC_MAX_COMP_CASE_FOLD_CODE_LEN = 3;
enum ONIGENC_GET_CASE_FOLD_CODES_MAX_NUM = 13;
/* 13 => Unicode:0x1ffc */

/* code range */
extern (D) auto ONIGENC_CODE_RANGE_NUM(T)(auto ref T range)
{
    return cast(int) range[0];
}

extern (D) auto ONIGENC_CODE_RANGE_FROM(T0, T1)(auto ref T0 range, auto ref T1 i)
{
    return range[(i * 2) + 1];
}

extern (D) auto ONIGENC_CODE_RANGE_TO(T0, T1)(auto ref T0 range, auto ref T1 i)
{
    return range[(i * 2) + 2];
}

struct OnigCaseFoldCodeItem
{
    int byte_len; /* argument(original) character(s) byte length */
    int code_len; /* number of code */
    OnigCodePoint[ONIGENC_MAX_COMP_CASE_FOLD_CODE_LEN] code;
}

struct OnigMetaCharTableType
{
    OnigCodePoint esc;
    OnigCodePoint anychar;
    OnigCodePoint anytime;
    OnigCodePoint zero_or_one_time;
    OnigCodePoint one_or_more_time;
    OnigCodePoint anychar_anytime;
}

alias OnigApplyAllCaseFoldFunc = int function (OnigCodePoint from, OnigCodePoint* to, int to_len, void* arg);

struct OnigEncodingTypeST
{
    int function (const(OnigUChar)* p) mbc_enc_len;
    const(char)* name;
    int max_enc_len;
    int min_enc_len;
    int function (const(OnigUChar)* p, const(OnigUChar)* end) is_mbc_newline;
    OnigCodePoint function (const(OnigUChar)* p, const(OnigUChar)* end) mbc_to_code;
    int function (OnigCodePoint code) code_to_mbclen;
    int function (OnigCodePoint code, OnigUChar* buf) code_to_mbc;
    int function (OnigCaseFoldType flag, const(OnigUChar*)* pp, const(OnigUChar)* end, OnigUChar* to) mbc_case_fold;
    int function (OnigCaseFoldType flag, OnigApplyAllCaseFoldFunc f, void* arg) apply_all_case_fold;
    int function (OnigCaseFoldType flag, const(OnigUChar)* p, const(OnigUChar)* end, OnigCaseFoldCodeItem[] acs) get_case_fold_codes_by_str;
    int function (OnigEncodingTypeST* enc, OnigUChar* p, OnigUChar* end) property_name_to_ctype;
    int function (OnigCodePoint code, OnigCtype ctype) is_code_ctype;
    int function (OnigCtype ctype, OnigCodePoint* sb_out, const(OnigCodePoint)*[] ranges) get_ctype_code_range;
    OnigUChar* function (const(OnigUChar)* start, const(OnigUChar)* p) left_adjust_char_head;
    int function (const(OnigUChar)* p, const(OnigUChar)* end) is_allowed_reverse_match;
    int function () init;
    int function () is_initialized;
    int function (const(OnigUChar)* s, const(OnigUChar)* end) is_valid_mbc_string;
}

alias OnigEncodingType = OnigEncodingTypeST;

alias OnigEncoding = OnigEncodingTypeST*;

extern __gshared OnigEncodingType OnigEncodingASCII;
extern __gshared OnigEncodingType OnigEncodingISO_8859_1;
extern __gshared OnigEncodingType OnigEncodingISO_8859_2;
extern __gshared OnigEncodingType OnigEncodingISO_8859_3;
extern __gshared OnigEncodingType OnigEncodingISO_8859_4;
extern __gshared OnigEncodingType OnigEncodingISO_8859_5;
extern __gshared OnigEncodingType OnigEncodingISO_8859_6;
extern __gshared OnigEncodingType OnigEncodingISO_8859_7;
extern __gshared OnigEncodingType OnigEncodingISO_8859_8;
extern __gshared OnigEncodingType OnigEncodingISO_8859_9;
extern __gshared OnigEncodingType OnigEncodingISO_8859_10;
extern __gshared OnigEncodingType OnigEncodingISO_8859_11;
extern __gshared OnigEncodingType OnigEncodingISO_8859_13;
extern __gshared OnigEncodingType OnigEncodingISO_8859_14;
extern __gshared OnigEncodingType OnigEncodingISO_8859_15;
extern __gshared OnigEncodingType OnigEncodingISO_8859_16;
extern __gshared OnigEncodingType OnigEncodingUTF8;
extern __gshared OnigEncodingType OnigEncodingUTF16_BE;
extern __gshared OnigEncodingType OnigEncodingUTF16_LE;
extern __gshared OnigEncodingType OnigEncodingUTF32_BE;
extern __gshared OnigEncodingType OnigEncodingUTF32_LE;
extern __gshared OnigEncodingType OnigEncodingEUC_JP;
extern __gshared OnigEncodingType OnigEncodingEUC_TW;
extern __gshared OnigEncodingType OnigEncodingEUC_KR;
extern __gshared OnigEncodingType OnigEncodingEUC_CN;
extern __gshared OnigEncodingType OnigEncodingSJIS;
extern __gshared OnigEncodingType OnigEncodingKOI8;
extern __gshared OnigEncodingType OnigEncodingKOI8_R;
extern __gshared OnigEncodingType OnigEncodingCP1251;
extern __gshared OnigEncodingType OnigEncodingBIG5;
extern __gshared OnigEncodingType OnigEncodingGB18030;

enum ONIG_ENCODING_ASCII = &OnigEncodingASCII;
enum ONIG_ENCODING_ISO_8859_1 = &OnigEncodingISO_8859_1;
enum ONIG_ENCODING_ISO_8859_2 = &OnigEncodingISO_8859_2;
enum ONIG_ENCODING_ISO_8859_3 = &OnigEncodingISO_8859_3;
enum ONIG_ENCODING_ISO_8859_4 = &OnigEncodingISO_8859_4;
enum ONIG_ENCODING_ISO_8859_5 = &OnigEncodingISO_8859_5;
enum ONIG_ENCODING_ISO_8859_6 = &OnigEncodingISO_8859_6;
enum ONIG_ENCODING_ISO_8859_7 = &OnigEncodingISO_8859_7;
enum ONIG_ENCODING_ISO_8859_8 = &OnigEncodingISO_8859_8;
enum ONIG_ENCODING_ISO_8859_9 = &OnigEncodingISO_8859_9;
enum ONIG_ENCODING_ISO_8859_10 = &OnigEncodingISO_8859_10;
enum ONIG_ENCODING_ISO_8859_11 = &OnigEncodingISO_8859_11;
enum ONIG_ENCODING_ISO_8859_13 = &OnigEncodingISO_8859_13;
enum ONIG_ENCODING_ISO_8859_14 = &OnigEncodingISO_8859_14;
enum ONIG_ENCODING_ISO_8859_15 = &OnigEncodingISO_8859_15;
enum ONIG_ENCODING_ISO_8859_16 = &OnigEncodingISO_8859_16;
enum ONIG_ENCODING_UTF8 = &OnigEncodingUTF8;
enum ONIG_ENCODING_UTF16_BE = &OnigEncodingUTF16_BE;
enum ONIG_ENCODING_UTF16_LE = &OnigEncodingUTF16_LE;
enum ONIG_ENCODING_UTF32_BE = &OnigEncodingUTF32_BE;
enum ONIG_ENCODING_UTF32_LE = &OnigEncodingUTF32_LE;
enum ONIG_ENCODING_EUC_JP = &OnigEncodingEUC_JP;
enum ONIG_ENCODING_EUC_TW = &OnigEncodingEUC_TW;
enum ONIG_ENCODING_EUC_KR = &OnigEncodingEUC_KR;
enum ONIG_ENCODING_EUC_CN = &OnigEncodingEUC_CN;
enum ONIG_ENCODING_SJIS = &OnigEncodingSJIS;
enum ONIG_ENCODING_KOI8 = &OnigEncodingKOI8;
enum ONIG_ENCODING_KOI8_R = &OnigEncodingKOI8_R;
enum ONIG_ENCODING_CP1251 = &OnigEncodingCP1251;
enum ONIG_ENCODING_BIG5 = &OnigEncodingBIG5;
enum ONIG_ENCODING_GB18030 = &OnigEncodingGB18030;

enum ONIG_ENCODING_UNDEF = cast(OnigEncoding) 0;

/* work size */
enum ONIGENC_CODE_TO_MBC_MAXLEN = 7;
enum ONIGENC_MBC_CASE_FOLD_MAXLEN = 18;
/* 18: 6(max-byte) * 3(case-fold chars) */

/* character types */
enum ONIGENC_CTYPE_NEWLINE = 0;
enum ONIGENC_CTYPE_ALPHA = 1;
enum ONIGENC_CTYPE_BLANK = 2;
enum ONIGENC_CTYPE_CNTRL = 3;
enum ONIGENC_CTYPE_DIGIT = 4;
enum ONIGENC_CTYPE_GRAPH = 5;
enum ONIGENC_CTYPE_LOWER = 6;
enum ONIGENC_CTYPE_PRINT = 7;
enum ONIGENC_CTYPE_PUNCT = 8;
enum ONIGENC_CTYPE_SPACE = 9;
enum ONIGENC_CTYPE_UPPER = 10;
enum ONIGENC_CTYPE_XDIGIT = 11;
enum ONIGENC_CTYPE_WORD = 12;
enum ONIGENC_CTYPE_ALNUM = 13; /* alpha || digit */
enum ONIGENC_CTYPE_ASCII = 14;
enum ONIGENC_MAX_STD_CTYPE = ONIGENC_CTYPE_ASCII;

extern (D) auto onig_enc_len(T0, T1, T2)(auto ref T0 enc, auto ref T1 p, auto ref T2 end)
{
    return ONIGENC_MBC_ENC_LEN(enc, p);
}

extern (D) auto ONIGENC_IS_UNDEF(T)(auto ref T enc)
{
    return enc == ONIG_ENCODING_UNDEF;
}

extern (D) auto ONIGENC_IS_SINGLEBYTE(T)(auto ref T enc)
{
    return ONIGENC_MBC_MAXLEN(enc) == 1;
}

extern (D) auto ONIGENC_IS_MBC_HEAD(T0, T1)(auto ref T0 enc, auto ref T1 p)
{
    return ONIGENC_MBC_ENC_LEN(enc, p) != 1;
}

extern (D) auto ONIGENC_IS_MBC_ASCII(T)(auto ref T p)
{
    return *p < 128;
}

extern (D) auto ONIGENC_IS_CODE_ASCII(T)(auto ref T code)
{
    return code < 128;
}

extern (D) auto ONIGENC_IS_MBC_WORD(T0, T1, T2)(auto ref T0 enc, auto ref T1 s, auto ref T2 end)
{
    return ONIGENC_IS_CODE_WORD(enc, ONIGENC_MBC_TO_CODE(enc, s, end));
}

// alias ONIGENC_IS_MBC_WORD_ASCII = onigenc_is_mbc_word_ascii;

extern (D) auto ONIGENC_NAME(T)(auto ref T enc)
{
    return enc.name;
}

// #define ONIGENC_MBC_CASE_FOLD(enc,flag,pp,end,buf) \
//   (enc)->mbc_case_fold(flag,(const OnigUChar** )pp,end,buf)
// #define ONIGENC_IS_ALLOWED_REVERSE_MATCH(enc,s,end) \
//         (enc)->is_allowed_reverse_match(s,end)
// #define ONIGENC_LEFT_ADJUST_CHAR_HEAD(enc,start,s) \
//         (enc)->left_adjust_char_head(start, s)
// #define ONIGENC_IS_VALID_MBC_STRING(enc,s,end) \
//         (enc)->is_valid_mbc_string(s,end)
// #define ONIGENC_APPLY_ALL_CASE_FOLD(enc,case_fold_flag,f,arg) \
//         (enc)->apply_all_case_fold(case_fold_flag,f,arg)
// #define ONIGENC_GET_CASE_FOLD_CODES_BY_STR(enc,case_fold_flag,p,end,acs) \
//        (enc)->get_case_fold_codes_by_str(case_fold_flag,p,end,acs)
// #define ONIGENC_STEP_BACK(enc,start,s,n) \
//         onigenc_step_back((enc),(start),(s),(n))
//
// #define ONIGENC_MBC_ENC_LEN(enc,p)             (enc)->mbc_enc_len(p)
// #define ONIGENC_MBC_MAXLEN(enc)               ((enc)->max_enc_len)
// #define ONIGENC_MBC_MAXLEN_DIST(enc)           ONIGENC_MBC_MAXLEN(enc)
// #define ONIGENC_MBC_MINLEN(enc)               ((enc)->min_enc_len)
// #define ONIGENC_IS_MBC_NEWLINE(enc,p,end)      (enc)->is_mbc_newline((p),(end))
// #define ONIGENC_MBC_TO_CODE(enc,p,end)         (enc)->mbc_to_code((p),(end))
// #define ONIGENC_CODE_TO_MBCLEN(enc,code)       (enc)->code_to_mbclen(code)
// #define ONIGENC_CODE_TO_MBC(enc,code,buf)      (enc)->code_to_mbc(code,buf)
// #define ONIGENC_PROPERTY_NAME_TO_CTYPE(enc,p,end) \
//   (enc)->property_name_to_ctype(enc,p,end)
//
// #define ONIGENC_IS_CODE_CTYPE(enc,code,ctype)  (enc)->is_code_ctype(code,ctype)
//
// #define ONIGENC_IS_CODE_NEWLINE(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_NEWLINE)
// #define ONIGENC_IS_CODE_GRAPH(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_GRAPH)
// #define ONIGENC_IS_CODE_PRINT(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_PRINT)
// #define ONIGENC_IS_CODE_ALNUM(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_ALNUM)
// #define ONIGENC_IS_CODE_ALPHA(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_ALPHA)
// #define ONIGENC_IS_CODE_LOWER(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_LOWER)
// #define ONIGENC_IS_CODE_UPPER(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_UPPER)
// #define ONIGENC_IS_CODE_CNTRL(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_CNTRL)
// #define ONIGENC_IS_CODE_PUNCT(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_PUNCT)
// #define ONIGENC_IS_CODE_SPACE(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_SPACE)
// #define ONIGENC_IS_CODE_BLANK(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_BLANK)
// #define ONIGENC_IS_CODE_DIGIT(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_DIGIT)
// #define ONIGENC_IS_CODE_XDIGIT(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_XDIGIT)
// #define ONIGENC_IS_CODE_WORD(enc,code) \
//         ONIGENC_IS_CODE_CTYPE(enc,code,ONIGENC_CTYPE_WORD)
//
// #define ONIGENC_GET_CTYPE_CODE_RANGE(enc,ctype,sbout,ranges) \
//         (enc)->get_ctype_code_range(ctype,sbout,ranges)
//
// ONIG_EXTERN
// OnigUChar* onigenc_step_back P_((OnigEncoding enc, const OnigUChar* start, const OnigUChar* s, int n));
//
//
// /* encoding API */
int onigenc_init ();
int onig_initialize_encoding (OnigEncoding enc);
int onigenc_set_default_encoding (OnigEncoding enc);
OnigEncoding onigenc_get_default_encoding ();
void onigenc_set_default_caseconv_table (const(OnigUChar)* table);
OnigUChar* onigenc_get_right_adjust_char_head_with_prev (
    OnigEncoding enc,
    const(OnigUChar)* start,
    const(OnigUChar)* s,
    const(OnigUChar*)* prev);
OnigUChar* onigenc_get_prev_char_head (
    OnigEncoding enc,
    const(OnigUChar)* start,
    const(OnigUChar)* s);
OnigUChar* onigenc_get_left_adjust_char_head (
    OnigEncoding enc,
    const(OnigUChar)* start,
    const(OnigUChar)* s);
OnigUChar* onigenc_get_right_adjust_char_head (
    OnigEncoding enc,
    const(OnigUChar)* start,
    const(OnigUChar)* s);
int onigenc_strlen (
    OnigEncoding enc,
    const(OnigUChar)* p,
    const(OnigUChar)* end);
int onigenc_strlen_null (OnigEncoding enc, const(OnigUChar)* p);
int onigenc_str_bytelen_null (OnigEncoding enc, const(OnigUChar)* p);
int onigenc_is_valid_mbc_string (
    OnigEncoding enc,
    const(OnigUChar)* s,
    const(OnigUChar)* end);

/* PART: regular expression */

/* config parameters */
enum ONIG_NREGION = 10;
enum ONIG_MAX_CAPTURE_NUM = 2147483647; /* 2**31 - 1 */
enum ONIG_MAX_BACKREF_NUM = 1000;
enum ONIG_MAX_REPEAT_NUM = 100000;
enum ONIG_MAX_MULTI_BYTE_RANGES_NUM = 10000;
/* constants */
enum ONIG_MAX_ERROR_MESSAGE_LEN = 90;

alias OnigOptionType = uint;

enum ONIG_OPTION_DEFAULT = ONIG_OPTION_NONE;

/* options */
enum ONIG_OPTION_NONE = 0U;
/* options (compile time) */
enum ONIG_OPTION_IGNORECASE = 1U;
enum ONIG_OPTION_EXTEND = ONIG_OPTION_IGNORECASE << 1;
enum ONIG_OPTION_MULTILINE = ONIG_OPTION_EXTEND << 1;
enum ONIG_OPTION_SINGLELINE = ONIG_OPTION_MULTILINE << 1;
enum ONIG_OPTION_FIND_LONGEST = ONIG_OPTION_SINGLELINE << 1;
enum ONIG_OPTION_FIND_NOT_EMPTY = ONIG_OPTION_FIND_LONGEST << 1;
enum ONIG_OPTION_NEGATE_SINGLELINE = ONIG_OPTION_FIND_NOT_EMPTY << 1;
enum ONIG_OPTION_DONT_CAPTURE_GROUP = ONIG_OPTION_NEGATE_SINGLELINE << 1;
enum ONIG_OPTION_CAPTURE_GROUP = ONIG_OPTION_DONT_CAPTURE_GROUP << 1;
/* options (search time) */
enum ONIG_OPTION_NOTBOL = ONIG_OPTION_CAPTURE_GROUP << 1;
enum ONIG_OPTION_NOTEOL = ONIG_OPTION_NOTBOL << 1;
enum ONIG_OPTION_POSIX_REGION = ONIG_OPTION_NOTEOL << 1;
enum ONIG_OPTION_CHECK_VALIDITY_OF_STRING = ONIG_OPTION_POSIX_REGION << 1;
/* #define ONIG_OPTION_CRLF_AS_LINE_SEPARATOR    (ONIG_OPTION_CHECK_VALIDITY_OF_STRING << 1) */
/* options (compile time) */
enum ONIG_OPTION_WORD_IS_ASCII = ONIG_OPTION_CHECK_VALIDITY_OF_STRING << 4;
enum ONIG_OPTION_DIGIT_IS_ASCII = ONIG_OPTION_WORD_IS_ASCII << 1;
enum ONIG_OPTION_SPACE_IS_ASCII = ONIG_OPTION_DIGIT_IS_ASCII << 1;
enum ONIG_OPTION_POSIX_IS_ASCII = ONIG_OPTION_SPACE_IS_ASCII << 1;

enum ONIG_OPTION_MAXBIT = ONIG_OPTION_POSIX_IS_ASCII; /* limit */

extern (D) auto ONIG_IS_OPTION_ON(T0, T1)(auto ref T0 options, auto ref T1 option)
{
    return options & option;
}

/* syntax */
struct OnigSyntaxType
{
    uint op;
    uint op2;
    uint behavior;
    OnigOptionType options; /* default option */
    OnigMetaCharTableType meta_char_table;
}

extern __gshared OnigSyntaxType OnigSyntaxASIS;
extern __gshared OnigSyntaxType OnigSyntaxPosixBasic;
extern __gshared OnigSyntaxType OnigSyntaxPosixExtended;
extern __gshared OnigSyntaxType OnigSyntaxEmacs;
extern __gshared OnigSyntaxType OnigSyntaxGrep;
extern __gshared OnigSyntaxType OnigSyntaxGnuRegex;
extern __gshared OnigSyntaxType OnigSyntaxJava;
extern __gshared OnigSyntaxType OnigSyntaxPerl;
extern __gshared OnigSyntaxType OnigSyntaxPerl_NG;
extern __gshared OnigSyntaxType OnigSyntaxRuby;
extern __gshared OnigSyntaxType OnigSyntaxOniguruma;

/* predefined syntaxes (see regsyntax.c) */
enum ONIG_SYNTAX_ASIS = &OnigSyntaxASIS;
enum ONIG_SYNTAX_POSIX_BASIC = &OnigSyntaxPosixBasic;
enum ONIG_SYNTAX_POSIX_EXTENDED = &OnigSyntaxPosixExtended;
enum ONIG_SYNTAX_EMACS = &OnigSyntaxEmacs;
enum ONIG_SYNTAX_GREP = &OnigSyntaxGrep;
enum ONIG_SYNTAX_GNU_REGEX = &OnigSyntaxGnuRegex;
enum ONIG_SYNTAX_JAVA = &OnigSyntaxJava;
enum ONIG_SYNTAX_PERL = &OnigSyntaxPerl;
enum ONIG_SYNTAX_PERL_NG = &OnigSyntaxPerl_NG;
enum ONIG_SYNTAX_RUBY = &OnigSyntaxRuby;
enum ONIG_SYNTAX_ONIGURUMA = &OnigSyntaxOniguruma;

/* default syntax */
extern __gshared OnigSyntaxType* OnigDefaultSyntax;
alias ONIG_SYNTAX_DEFAULT = OnigDefaultSyntax;

/* syntax (operators) */
enum ONIG_SYN_OP_VARIABLE_META_CHARACTERS = 1U << 0;
enum ONIG_SYN_OP_DOT_ANYCHAR = 1U << 1; /* . */
enum ONIG_SYN_OP_ASTERISK_ZERO_INF = 1U << 2; /* * */
enum ONIG_SYN_OP_ESC_ASTERISK_ZERO_INF = 1U << 3;
enum ONIG_SYN_OP_PLUS_ONE_INF = 1U << 4; /* + */
enum ONIG_SYN_OP_ESC_PLUS_ONE_INF = 1U << 5;
enum ONIG_SYN_OP_QMARK_ZERO_ONE = 1U << 6; /* ? */
enum ONIG_SYN_OP_ESC_QMARK_ZERO_ONE = 1U << 7;
enum ONIG_SYN_OP_BRACE_INTERVAL = 1U << 8; /* {lower,upper} */
enum ONIG_SYN_OP_ESC_BRACE_INTERVAL = 1U << 9; /* \{lower,upper\} */
enum ONIG_SYN_OP_VBAR_ALT = 1U << 10; /* | */
enum ONIG_SYN_OP_ESC_VBAR_ALT = 1U << 11; /* \| */
enum ONIG_SYN_OP_LPAREN_SUBEXP = 1U << 12; /* (...)   */
enum ONIG_SYN_OP_ESC_LPAREN_SUBEXP = 1U << 13; /* \(...\) */
enum ONIG_SYN_OP_ESC_AZ_BUF_ANCHOR = 1U << 14; /* \A, \Z, \z */
enum ONIG_SYN_OP_ESC_CAPITAL_G_BEGIN_ANCHOR = 1U << 15; /* \G     */
enum ONIG_SYN_OP_DECIMAL_BACKREF = 1U << 16; /* \num   */
enum ONIG_SYN_OP_BRACKET_CC = 1U << 17; /* [...]  */
enum ONIG_SYN_OP_ESC_W_WORD = 1U << 18; /* \w, \W */
enum ONIG_SYN_OP_ESC_LTGT_WORD_BEGIN_END = 1U << 19; /* \<. \> */
enum ONIG_SYN_OP_ESC_B_WORD_BOUND = 1U << 20; /* \b, \B */
enum ONIG_SYN_OP_ESC_S_WHITE_SPACE = 1U << 21; /* \s, \S */
enum ONIG_SYN_OP_ESC_D_DIGIT = 1U << 22; /* \d, \D */
enum ONIG_SYN_OP_LINE_ANCHOR = 1U << 23; /* ^, $   */
enum ONIG_SYN_OP_POSIX_BRACKET = 1U << 24; /* [:xxxx:] */
enum ONIG_SYN_OP_QMARK_NON_GREEDY = 1U << 25; /* ??,*?,+?,{n,m}? */
enum ONIG_SYN_OP_ESC_CONTROL_CHARS = 1U << 26; /* \n,\r,\t,\a ... */
enum ONIG_SYN_OP_ESC_C_CONTROL = 1U << 27; /* \cx  */
enum ONIG_SYN_OP_ESC_OCTAL3 = 1U << 28; /* \OOO */
enum ONIG_SYN_OP_ESC_X_HEX2 = 1U << 29; /* \xHH */
enum ONIG_SYN_OP_ESC_X_BRACE_HEX8 = 1U << 30; /* \x{7HHHHHHH} */
enum ONIG_SYN_OP_ESC_O_BRACE_OCTAL = 1U << 31; /* \o{1OOOOOOOOOO} */

enum ONIG_SYN_OP2_ESC_CAPITAL_Q_QUOTE = 1U << 0; /* \Q...\E */
enum ONIG_SYN_OP2_QMARK_GROUP_EFFECT = 1U << 1; /* (?...) */
enum ONIG_SYN_OP2_OPTION_PERL = 1U << 2; /* (?imsx),(?-imsx) */
enum ONIG_SYN_OP2_OPTION_RUBY = 1U << 3; /* (?imx), (?-imx)  */
enum ONIG_SYN_OP2_PLUS_POSSESSIVE_REPEAT = 1U << 4; /* ?+,*+,++ */
enum ONIG_SYN_OP2_PLUS_POSSESSIVE_INTERVAL = 1U << 5; /* {n,m}+   */
enum ONIG_SYN_OP2_CCLASS_SET_OP = 1U << 6; /* [...&&..[..]..] */
enum ONIG_SYN_OP2_QMARK_LT_NAMED_GROUP = 1U << 7; /* (?<name>...) */
enum ONIG_SYN_OP2_ESC_K_NAMED_BACKREF = 1U << 8; /* \k<name> */
enum ONIG_SYN_OP2_ESC_G_SUBEXP_CALL = 1U << 9; /* \g<name>, \g<n> */
enum ONIG_SYN_OP2_ATMARK_CAPTURE_HISTORY = 1U << 10; /* (?@..),(?@<x>..) */
enum ONIG_SYN_OP2_ESC_CAPITAL_C_BAR_CONTROL = 1U << 11; /* \C-x */
enum ONIG_SYN_OP2_ESC_CAPITAL_M_BAR_META = 1U << 12; /* \M-x */
enum ONIG_SYN_OP2_ESC_V_VTAB = 1U << 13; /* \v as VTAB */
enum ONIG_SYN_OP2_ESC_U_HEX4 = 1U << 14; /* \uHHHH */
enum ONIG_SYN_OP2_ESC_GNU_BUF_ANCHOR = 1U << 15; /* \`, \' */
enum ONIG_SYN_OP2_ESC_P_BRACE_CHAR_PROPERTY = 1U << 16; /* \p{...}, \P{...} */
enum ONIG_SYN_OP2_ESC_P_BRACE_CIRCUMFLEX_NOT = 1U << 17; /* \p{^..}, \P{^..} */
/* #define ONIG_SYN_OP2_CHAR_PROPERTY_PREFIX_IS (1U<<18) */
enum ONIG_SYN_OP2_ESC_H_XDIGIT = 1U << 19; /* \h, \H */
enum ONIG_SYN_OP2_INEFFECTIVE_ESCAPE = 1U << 20; /* \ */
enum ONIG_SYN_OP2_QMARK_LPAREN_IF_ELSE = 1U << 21; /* (?(n)) (?(...)...|...) */
enum ONIG_SYN_OP2_ESC_CAPITAL_K_KEEP = 1U << 22; /* \K */
enum ONIG_SYN_OP2_ESC_CAPITAL_R_GENERAL_NEWLINE = 1U << 23; /* \R \r\n else [\x0a-\x0d] */
enum ONIG_SYN_OP2_ESC_CAPITAL_N_O_SUPER_DOT = 1U << 24; /* \N (?-m:.), \O (?m:.) */
enum ONIG_SYN_OP2_QMARK_TILDE_ABSENT_GROUP = 1U << 25; /* (?~...) */
enum ONIG_SYN_OP2_ESC_X_Y_GRAPHEME_CLUSTER = 1U << 26; /* \X \y \Y */
enum ONIG_SYN_OP2_QMARK_PERL_SUBEXP_CALL = 1U << 27; /* (?R), (?&name)... */

/* syntax (behavior) */
enum ONIG_SYN_CONTEXT_INDEP_ANCHORS = 1U << 31; /* not implemented */
enum ONIG_SYN_CONTEXT_INDEP_REPEAT_OPS = 1U << 0; /* ?, *, +, {n,m} */
enum ONIG_SYN_CONTEXT_INVALID_REPEAT_OPS = 1U << 1; /* error or ignore */
enum ONIG_SYN_ALLOW_UNMATCHED_CLOSE_SUBEXP = 1U << 2; /* ...)... */
enum ONIG_SYN_ALLOW_INVALID_INTERVAL = 1U << 3; /* {??? */
enum ONIG_SYN_ALLOW_INTERVAL_LOW_ABBREV = 1U << 4; /* {,n} => {0,n} */
enum ONIG_SYN_STRICT_CHECK_BACKREF = 1U << 5; /* /(\1)/,/\1()/ ..*/
enum ONIG_SYN_DIFFERENT_LEN_ALT_LOOK_BEHIND = 1U << 6; /* (?<=a|bc) */
enum ONIG_SYN_CAPTURE_ONLY_NAMED_GROUP = 1U << 7; /* see doc/RE */
enum ONIG_SYN_ALLOW_MULTIPLEX_DEFINITION_NAME = 1U << 8; /* (?<x>)(?<x>) */
enum ONIG_SYN_FIXED_INTERVAL_IS_GREEDY_ONLY = 1U << 9; /* a{n}?=(?:a{n})? */

/* syntax (behavior) in char class [...] */
enum ONIG_SYN_NOT_NEWLINE_IN_NEGATIVE_CC = 1U << 20; /* [^...] */
enum ONIG_SYN_BACKSLASH_ESCAPE_IN_CC = 1U << 21; /* [..\w..] etc.. */
enum ONIG_SYN_ALLOW_EMPTY_RANGE_IN_CC = 1U << 22;
enum ONIG_SYN_ALLOW_DOUBLE_RANGE_OP_IN_CC = 1U << 23; /* [0-9-a]=[0-9\-a] */
/* syntax (behavior) warning */
enum ONIG_SYN_WARN_CC_OP_NOT_ESCAPED = 1U << 24; /* [,-,] */
enum ONIG_SYN_WARN_REDUNDANT_NESTED_REPEAT = 1U << 25; /* (?:a*)+ */

/* meta character specifiers (onig_set_meta_char()) */
enum ONIG_META_CHAR_ESCAPE = 0;
enum ONIG_META_CHAR_ANYCHAR = 1;
enum ONIG_META_CHAR_ANYTIME = 2;
enum ONIG_META_CHAR_ZERO_OR_ONE_TIME = 3;
enum ONIG_META_CHAR_ONE_OR_MORE_TIME = 4;
enum ONIG_META_CHAR_ANYCHAR_ANYTIME = 5;

enum ONIG_INEFFECTIVE_META_CHAR = 0;

/* error codes */
extern (D) auto ONIG_IS_PATTERN_ERROR(T)(auto ref T ecode)
{
    return ecode <= -100 && ecode > -1000;
}

/* normal return */
enum ONIG_NORMAL = 0;
enum ONIG_MISMATCH = -1;
enum ONIG_NO_SUPPORT_CONFIG = -2;

/* internal error */
enum ONIGERR_MEMORY = -5;
enum ONIGERR_TYPE_BUG = -6;
enum ONIGERR_PARSER_BUG = -11;
enum ONIGERR_STACK_BUG = -12;
enum ONIGERR_UNDEFINED_BYTECODE = -13;
enum ONIGERR_UNEXPECTED_BYTECODE = -14;
enum ONIGERR_MATCH_STACK_LIMIT_OVER = -15;
enum ONIGERR_PARSE_DEPTH_LIMIT_OVER = -16;
enum ONIGERR_TRY_IN_MATCH_LIMIT_OVER = -17;
enum ONIGERR_DEFAULT_ENCODING_IS_NOT_SETTED = -21;
enum ONIGERR_SPECIFIED_ENCODING_CANT_CONVERT_TO_WIDE_CHAR = -22;
enum ONIGERR_FAIL_TO_INITIALIZE = -23;
/* general error */
enum ONIGERR_INVALID_ARGUMENT = -30;
/* syntax error */
enum ONIGERR_END_PATTERN_AT_LEFT_BRACE = -100;
enum ONIGERR_END_PATTERN_AT_LEFT_BRACKET = -101;
enum ONIGERR_EMPTY_CHAR_CLASS = -102;
enum ONIGERR_PREMATURE_END_OF_CHAR_CLASS = -103;
enum ONIGERR_END_PATTERN_AT_ESCAPE = -104;
enum ONIGERR_END_PATTERN_AT_META = -105;
enum ONIGERR_END_PATTERN_AT_CONTROL = -106;
enum ONIGERR_META_CODE_SYNTAX = -108;
enum ONIGERR_CONTROL_CODE_SYNTAX = -109;
enum ONIGERR_CHAR_CLASS_VALUE_AT_END_OF_RANGE = -110;
enum ONIGERR_CHAR_CLASS_VALUE_AT_START_OF_RANGE = -111;
enum ONIGERR_UNMATCHED_RANGE_SPECIFIER_IN_CHAR_CLASS = -112;
enum ONIGERR_TARGET_OF_REPEAT_OPERATOR_NOT_SPECIFIED = -113;
enum ONIGERR_TARGET_OF_REPEAT_OPERATOR_INVALID = -114;
enum ONIGERR_NESTED_REPEAT_OPERATOR = -115;
enum ONIGERR_UNMATCHED_CLOSE_PARENTHESIS = -116;
enum ONIGERR_END_PATTERN_WITH_UNMATCHED_PARENTHESIS = -117;
enum ONIGERR_END_PATTERN_IN_GROUP = -118;
enum ONIGERR_UNDEFINED_GROUP_OPTION = -119;
enum ONIGERR_INVALID_POSIX_BRACKET_TYPE = -121;
enum ONIGERR_INVALID_LOOK_BEHIND_PATTERN = -122;
enum ONIGERR_INVALID_REPEAT_RANGE_PATTERN = -123;
/* values error (syntax error) */
enum ONIGERR_TOO_BIG_NUMBER = -200;
enum ONIGERR_TOO_BIG_NUMBER_FOR_REPEAT_RANGE = -201;
enum ONIGERR_UPPER_SMALLER_THAN_LOWER_IN_REPEAT_RANGE = -202;
enum ONIGERR_EMPTY_RANGE_IN_CHAR_CLASS = -203;
enum ONIGERR_MISMATCH_CODE_LENGTH_IN_CLASS_RANGE = -204;
enum ONIGERR_TOO_MANY_MULTI_BYTE_RANGES = -205;
enum ONIGERR_TOO_SHORT_MULTI_BYTE_STRING = -206;
enum ONIGERR_TOO_BIG_BACKREF_NUMBER = -207;
enum ONIGERR_INVALID_BACKREF = -208;
enum ONIGERR_NUMBERED_BACKREF_OR_CALL_NOT_ALLOWED = -209;
enum ONIGERR_TOO_MANY_CAPTURES = -210;
enum ONIGERR_TOO_LONG_WIDE_CHAR_VALUE = -212;
enum ONIGERR_EMPTY_GROUP_NAME = -214;
enum ONIGERR_INVALID_GROUP_NAME = -215;
enum ONIGERR_INVALID_CHAR_IN_GROUP_NAME = -216;
enum ONIGERR_UNDEFINED_NAME_REFERENCE = -217;
enum ONIGERR_UNDEFINED_GROUP_REFERENCE = -218;
enum ONIGERR_MULTIPLEX_DEFINED_NAME = -219;
enum ONIGERR_MULTIPLEX_DEFINITION_NAME_CALL = -220;
enum ONIGERR_NEVER_ENDING_RECURSION = -221;
enum ONIGERR_GROUP_NUMBER_OVER_FOR_CAPTURE_HISTORY = -222;
enum ONIGERR_INVALID_CHAR_PROPERTY_NAME = -223;
enum ONIGERR_INVALID_IF_ELSE_SYNTAX = -224;
enum ONIGERR_INVALID_ABSENT_GROUP_PATTERN = -225;
enum ONIGERR_INVALID_ABSENT_GROUP_GENERATOR_PATTERN = -226;
enum ONIGERR_INVALID_CODE_POINT_VALUE = -400;
enum ONIGERR_INVALID_WIDE_CHAR_VALUE = -400;
enum ONIGERR_TOO_BIG_WIDE_CHAR_VALUE = -401;
enum ONIGERR_NOT_SUPPORTED_ENCODING_COMBINATION = -402;
enum ONIGERR_INVALID_COMBINATION_OF_OPTIONS = -403;
enum ONIGERR_TOO_MANY_USER_DEFINED_OBJECTS = -404;
enum ONIGERR_TOO_LONG_PROPERTY_NAME = -405;
enum ONIGERR_LIBRARY_IS_NOT_INITIALIZED = -500;

/* errors related to thread */
/* #define ONIGERR_OVER_THREAD_PASS_LIMIT_COUNT                -1001 */

/* must be smaller than MEM_STATUS_BITS_NUM (unsigned int * 8) */
enum ONIG_MAX_CAPTURE_HISTORY_GROUP = 31;

extern (D) auto ONIG_IS_CAPTURE_HISTORY_GROUP(T0, T1)(auto ref T0 r, auto ref T1 i)
{
    return i <= ONIG_MAX_CAPTURE_HISTORY_GROUP && r.list && r.list[i];
}

struct OnigCaptureTreeNodeStruct
{
    int group; /* group number */
    int beg;
    int end;
    int allocated;
    int num_childs;
    OnigCaptureTreeNodeStruct** childs;
}

alias OnigCaptureTreeNode = OnigCaptureTreeNodeStruct;

/* match result region type */
struct re_registers
{
    int allocated;
    int num_regs;
    int* beg;
    int* end;
    /* extended */
    OnigCaptureTreeNode* history_root; /* capture history tree root */
}

/* capture tree traverse */
enum ONIG_TRAVERSE_CALLBACK_AT_FIRST = 1;
enum ONIG_TRAVERSE_CALLBACK_AT_LAST = 2;
enum ONIG_TRAVERSE_CALLBACK_AT_BOTH = ONIG_TRAVERSE_CALLBACK_AT_FIRST | ONIG_TRAVERSE_CALLBACK_AT_LAST;

enum ONIG_REGION_NOTPOS = -1;

alias OnigRegion = re_registers;

struct OnigErrorInfo
{
    OnigEncoding enc;
    OnigUChar* par;
    OnigUChar* par_end;
}

struct OnigRepeatRange
{
    int lower;
    int upper;
}

alias OnigWarnFunc = void function (const(char)* s);
void onig_null_warn (const(char)* s);
alias ONIG_NULL_WARN = onig_null_warn;

enum ONIG_CHAR_TABLE_SIZE = 256;

struct re_pattern_buffer
{
    /* common members of BBuf(bytes-buffer) */
    ubyte* p; /* compiled pattern */
    uint used; /* used space for p */
    uint alloc; /* allocated space for p */

    int num_mem; /* used memory(...) num counted from 1 */
    int num_repeat; /* OP_REPEAT/OP_REPEAT_NG id-counter */
    int num_null_check; /* OP_EMPTY_CHECK_START/END id counter */
    int num_comb_exp_check; /* combination explosion check */
    int num_call; /* number of subexp call */
    uint capture_history; /* (?@...) flag (1-31) */
    uint bt_mem_start; /* need backtrack flag */
    uint bt_mem_end; /* need backtrack flag */
    int stack_pop_level;
    int repeat_range_alloc;
    OnigRepeatRange* repeat_range;

    OnigEncoding enc;
    OnigOptionType options;
    OnigSyntaxType* syntax;
    OnigCaseFoldType case_fold_flag;
    void* name_table;

    /* optimization info (string search, char-map and anchors) */
    int optimize; /* optimize flag */
    int threshold_len; /* search str-length for apply optimize */
    int anchor; /* BEGIN_BUF, BEGIN_POS, (SEMI_)END_BUF */
    OnigLen anchor_dmin; /* (SEMI_)END_BUF anchor distance */
    OnigLen anchor_dmax; /* (SEMI_)END_BUF anchor distance */
    int sub_anchor; /* start-anchor for exact or map */
    ubyte* exact;
    ubyte* exact_end;
    ubyte[ONIG_CHAR_TABLE_SIZE] map; /* used as BM skip or char-map */
    int* int_map; /* BM skip for exact_len > 255 */
    int* int_map_backward; /* BM skip for backward search */
    OnigLen dmin; /* min-distance of exact or map */
    OnigLen dmax; /* max-distance of exact or map */

    /* regex_t link chain */
    re_pattern_buffer* chain; /* escape compile-conflict */
}

alias OnigRegexType = re_pattern_buffer;

alias OnigRegex = re_pattern_buffer*;

alias regex_t = re_pattern_buffer;

struct OnigCompileInfo
{
    int num_of_elements;
    OnigEncoding pattern_enc;
    OnigEncoding target_enc;
    OnigSyntaxType* syntax;
    OnigOptionType option;
    OnigCaseFoldType case_fold_flag;
}

/* Oniguruma Native API */

int onig_initialize (OnigEncoding* encodings, int n);
/* onig_init(): deprecated function. Use onig_initialize(). */
int onig_init ();
int onig_error_code_to_str (OnigUChar* s, int err_code, ...);
void onig_set_warn_func (OnigWarnFunc f);
void onig_set_verb_warn_func (OnigWarnFunc f);
int onig_new (
    OnigRegex*,
    const(OnigUChar)* pattern,
    const(OnigUChar)* pattern_end,
    OnigOptionType option,
    OnigEncoding enc,
    OnigSyntaxType* syntax,
    OnigErrorInfo* einfo);
int onig_reg_init (
    regex_t* reg,
    OnigOptionType option,
    OnigCaseFoldType case_fold_flag,
    OnigEncoding enc,
    OnigSyntaxType* syntax);
int onig_new_without_alloc (OnigRegex, const(OnigUChar)* pattern, const(OnigUChar)* pattern_end, OnigOptionType option, OnigEncoding enc, OnigSyntaxType* syntax, OnigErrorInfo* einfo);
int onig_new_deluxe (
    OnigRegex* reg,
    const(OnigUChar)* pattern,
    const(OnigUChar)* pattern_end,
    OnigCompileInfo* ci,
    OnigErrorInfo* einfo);
void onig_free (OnigRegex);
void onig_free_body (OnigRegex);
int onig_scan (
    regex_t* reg,
    const(OnigUChar)* str,
    const(OnigUChar)* end,
    OnigRegion* region,
    OnigOptionType option,
    int function (int, int, OnigRegion*, void*) scan_callback,
    void* callback_arg);
int onig_search (
    OnigRegex,
    const(OnigUChar)* str,
    const(OnigUChar)* end,
    const(OnigUChar)* start,
    const(OnigUChar)* range,
    OnigRegion* region,
    OnigOptionType option);
int onig_match (
    OnigRegex,
    const(OnigUChar)* str,
    const(OnigUChar)* end,
    const(OnigUChar)* at,
    OnigRegion* region,
    OnigOptionType option);
OnigRegion* onig_region_new ();
void onig_region_init (OnigRegion* region);
void onig_region_free (OnigRegion* region, int free_self);
void onig_region_copy (OnigRegion* to, OnigRegion* from);
void onig_region_clear (OnigRegion* region);
int onig_region_resize (OnigRegion* region, int n);
int onig_region_set (OnigRegion* region, int at, int beg, int end);
int onig_name_to_group_numbers (
    OnigRegex reg,
    const(OnigUChar)* name,
    const(OnigUChar)* name_end,
    int** nums);
int onig_name_to_backref_number (
    OnigRegex reg,
    const(OnigUChar)* name,
    const(OnigUChar)* name_end,
    OnigRegion* region);
int onig_foreach_name (
    OnigRegex reg,
    int function (const(OnigUChar)*, const(OnigUChar)*, int, int*, OnigRegex, void*) func,
    void* arg);
int onig_number_of_names (OnigRegex reg);
int onig_number_of_captures (OnigRegex reg);
int onig_number_of_capture_histories (OnigRegex reg);
OnigCaptureTreeNode* onig_get_capture_tree (OnigRegion* region);
int onig_capture_tree_traverse (
    OnigRegion* region,
    int at,
    int function (int, int, int, int, int, void*) callback_func,
    void* arg);
int onig_noname_group_capture_is_active (OnigRegex reg);
OnigEncoding onig_get_encoding (OnigRegex reg);
OnigOptionType onig_get_options (OnigRegex reg);
OnigCaseFoldType onig_get_case_fold_flag (OnigRegex reg);
OnigSyntaxType* onig_get_syntax (OnigRegex reg);
int onig_set_default_syntax (OnigSyntaxType* syntax);
void onig_copy_syntax (OnigSyntaxType* to, OnigSyntaxType* from);
uint onig_get_syntax_op (OnigSyntaxType* syntax);
uint onig_get_syntax_op2 (OnigSyntaxType* syntax);
uint onig_get_syntax_behavior (OnigSyntaxType* syntax);
OnigOptionType onig_get_syntax_options (OnigSyntaxType* syntax);
void onig_set_syntax_op (OnigSyntaxType* syntax, uint op);
void onig_set_syntax_op2 (OnigSyntaxType* syntax, uint op2);
void onig_set_syntax_behavior (OnigSyntaxType* syntax, uint behavior);
void onig_set_syntax_options (OnigSyntaxType* syntax, OnigOptionType options);
int onig_set_meta_char (OnigSyntaxType* syntax, uint what, OnigCodePoint code);
void onig_copy_encoding (OnigEncoding to, OnigEncoding from);
OnigCaseFoldType onig_get_default_case_fold_flag ();
int onig_set_default_case_fold_flag (OnigCaseFoldType case_fold_flag);
uint onig_get_match_stack_limit_size ();
int onig_set_match_stack_limit_size (uint size);
c_ulong onig_get_try_in_match_limit ();
int onig_set_try_in_match_limit (c_ulong n);
uint onig_get_parse_depth_limit ();
int onig_set_capture_num_limit (int num);
int onig_set_parse_depth_limit (uint depth);
int onig_unicode_define_user_property (
    const(char)* name,
    OnigCodePoint* ranges);
int onig_end ();
const(char)* onig_version ();
const(char)* onig_copyright ();

/* ONIGURUMA_H */
