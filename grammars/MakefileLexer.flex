package name.kropp.intellij.makefile;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import name.kropp.intellij.makefile.psi.MakefileTypes;

import static com.intellij.psi.TokenType.BAD_CHARACTER;
import static com.intellij.psi.TokenType.WHITE_SPACE;
import static name.kropp.intellij.makefile.psi.MakefileTypes.*;

%%

%{
  public _MakefileLexer() {
    this((java.io.Reader)null);
  }
%}

%public
%class _MakefileLexer
%implements FlexLexer
%function advance
%type IElementType
%unicode

EOL=[\r\n]+
SPACES=[ \t]+
TAB=\t
COMMENT="#"[^\r\n]*
VARIABLE_VALUE=[^\r\n]
COLON=":"
PIPE="|"
ASSIGN=("="|":="|"::="|"?="|"!="|"+=")

FILENAME_CHARACTER=[^:\ \r\n\t]
COMMAND=[^\r\n]+

%state PREREQUISITES INCLUDES COMMANDS VARIABLE CONDITIONALS

%%

<YYINITIAL> {
    {COMMENT}          { return COMMENT; }
    {TAB}+             { yybegin(COMMANDS); return WHITE_SPACE; }
    {EOL}              { return WHITE_SPACE; }
    {SPACES}           { return WHITE_SPACE; }
    {COLON}            { yybegin(PREREQUISITES); return COLON; }
    {ASSIGN}           { yybegin(VARIABLE); return ASSIGN; }
    "include"          { yybegin(INCLUDES); return KEYWORD_INCLUDE; }
    "ifeq"             { yybegin(CONDITIONALS); return KEYWORD_IFEQ; }
    "else"             { return KEYWORD_ELSE; }
    "endif"            { return KEYWORD_ENDIF; }
    {FILENAME_CHARACTER}+   { return IDENTIFIER; }
}

<PREREQUISITES> {
    {PIPE}                  { return PIPE; }
    {FILENAME_CHARACTER}+   { return IDENTIFIER; }
    {EOL}                   { yybegin(YYINITIAL); return EOL; }
    <<EOF>>                 { yypushback(yylength()); yybegin(YYINITIAL); return EOL; }
    {SPACES}                { return WHITE_SPACE; }
}

<INCLUDES> {
    {FILENAME_CHARACTER}+   { return IDENTIFIER; }
    {EOL}                   { yybegin(YYINITIAL); return EOL; }
    <<EOF>>                 { yypushback(yylength()); yybegin(YYINITIAL); return EOL; }
    {SPACES}                { return WHITE_SPACE; }
}


<COMMANDS> {COMMAND}                   { yybegin(YYINITIAL); return COMMAND; }

<VARIABLE> {VARIABLE_VALUE}+           { yybegin(VARIABLE); return VARIABLE_VALUE; }
<VARIABLE> {EOL}                       { yybegin(YYINITIAL); return WHITE_SPACE; }

<CONDITIONALS> {
    {FILENAME_CHARACTER}+      { yybegin(YYINITIAL); return CONDITION; }
    {SPACES}                   { return WHITE_SPACE; }
    {EOL}                      { yybegin(YYINITIAL); return WHITE_SPACE; }
}

[^] { return BAD_CHARACTER; }
