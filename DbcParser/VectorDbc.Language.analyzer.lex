%namespace DbcParser
%scannertype VectorDbcScanner
%visibility internal
%tokentype Token

%option stack, minimize, parser, verbose, persistbuffer, noembedbuffers 


Eol             (\r\n?|\n)
Identifier      [A-Za-z][A-Za-z0-9_]+
Space           [ ]
Number          [\-]?[0-9]+(\.[0-9]+)?



%x STATE_STRING

%{
public int line = 1;
%}

%%

/* Scanner body */

{Eol}           { line++; return (int)Token.EOL; }

{Space}+		/* skip */

":" |
";" |
"+" |
"@" |
"-" |
"(" |
")" |
"[" |
"]" |
"," |
"|"             { return (int)yytext[0]; }

\"              { BEGIN(STATE_STRING); yylval.s = ""; }

VERSION         { return (int)Token.VERSION; }
BO\_            { return (int)Token.BO; }
NS\_            { return (int)Token.NS; }
BS\_            { return (int)Token.BS; }
BU\_            { return (int)Token.BU; }
VAL_TABLE\_     { return (int)Token.VAL_TABLE; }
SG\_            { return (int)Token.SG; }
CM\_            { return (int)Token.CM; }
BA\_            { return (int)Token.BA; }
BA\_DEF\_       { return (int)Token.BA_DEF; }
BA\_DEF\_DEF\_  { return (int)Token.BA_DEF_DEF; }
VAL\_           { return (int)Token.VAL; }
EV\_            { return (int)Token.EV; }
SIG\_VALTYPE\_  { return (int)Token.SIG_VALTYPE; }

FLOAT           { return (int)Token.FLOAT; }
ENUM            { return (int)Token.ENUM; }
INT             { return (int)Token.INT; }
STRING          { return (int)Token.STRING; }

{Identifier}    { yylval.s = yytext; return (int)Token.IDENTIFIER; }

{Number}		{ GetNumber(); return (int)Token.NUMBER; }

\t              { return (int)Token.TAB; }


<STATE_STRING> {
	\"  { BEGIN(INITIAL); return (int)Token.QUOTED_STRING; }
	\\. { yylval.s += yytext; }
	.   { yylval.s += yytext; }
}

%%