/* lexical grammar */

%s expect_object

%%

\#[^\n]*                /* return 'COMMENT'; */
"{"                     { this.begin('expect_object'); return '{'; }
<expect_object>[\s\n]+  /* skip space in object declaration */
<expect_object>"}"      { this.popState(); return '}'; }
<INITIAL>[\s]*<<EOF>>		%{
                          // remaining DEDENTs implied by EOF, regardless of tabs/spaces
                          parser.forceDedent = parser.forceDedent || 0;
                          if (parser.forceDedent) {
                            parser.forceDedent -= 1;
                            this.unput(yytext);
                            return 'DEDENT';
                          }
                          var tokens = [];
                          while (0 < _iemitstack[0]) {
                            tokens.unshift("DEDENT");
                            _iemitstack.shift();
                          }
                          if (tokens.length) {
                            parser.forceDedent = tokens.length - 1;
                            this.unput(yytext);
                            return 'DEDENT';
                          } else return 'EOF';
                        %}
[\n\r]+[\s]*/![^\n\r]  /* eat blank lines */
<INITIAL>[\n\r][\s]*   %{
                          parser.forceDedent = parser.forceDedent || 0;
                          if (parser.forceDedent) {
                            parser.forceDedent -= 1;
                            this.unput(yytext);
                            return 'DEDENT';
                          }
                          var indentation = yytext.length - yytext.search(/\s/) - 1;
                          if (indentation > _iemitstack[0]) {
                            _iemitstack.unshift(indentation);
                            return 'INDENT';
                          }
                          var tokens = [];
                          while (indentation < _iemitstack[0]) {
                            tokens.unshift("DEDENT");
                            _iemitstack.shift();
                          }
                          if (tokens.length) {
                            parser.forceDedent = tokens.length - 1;
                            this.unput(yytext);
                            return 'DEDENT';
                          };
                        %}
[\s]+                    /*  skip space */
[0-9]+("."[0-9]+)?\b    return 'NUMBER';
\'\'\'[^\']+\'\'\'      return 'MULTILINE_STRING'
\"[^\"]*\"              return 'STRING';
\'[^\']*\'              return 'STRING';
"*"                     return '*'
"/"                     return '/'
"-"                     return '-'
"+"                     return '+'
"=="                    return 'EQ'
"!="                    return 'NE'
"and"                   return 'AND'
"or"                    return 'OR'
"="                     return '='
"("                     return '('
")"                     return ')'
"["                     return '['
"]"                     return ']'
\.                      return 'DOT'
","                     return 'COMMA'
":"                     return ':'
"if"                    return 'IF'
"else:"                 return 'ELSE'
"True"                  return 'TRUE'
"False"                 return 'FALSE'
[a-zA-Z_][a-zA-Z_0-9]*  return 'TOKEN'
/* .                       return 'INVALID' */

%%

_iemitstack = [0]
