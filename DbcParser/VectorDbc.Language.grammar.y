%namespace DbcParser
%partial
%parsertype VectorDbcParser
%visibility internal
%tokentype Token

%union { 
			public Int64 n; 
			public string s; 
			public List<string> sl;
			public AttributeLimits     ba_def_type;
			public AttributeDefinition ba_def;
			public AttributeDefault    ba_def_def;
			public List<Signal>        sgs;
			public Signal              sg;
			public SignalType          sg_type;
			public SignalRange         sg_range;
			public Message             bo;
	   }

%start main

%token <n> NUMBER
%token <s> IDENTIFIER
%token EOL
%token <s> QUOTED_STRING
%token TAB

%token BO
%token NS
%token BS
%token BU
%token VAL_TABLE
%token SG
%token CM
%token BA
%token BA_DEF
%token BA_DEF_DEF
%token VERSION

%token FLOAT
%token ENUM
%token INT
%token STRING

%type <s>            ba_def_object
%type <sl>           string_list identifier_list
%type <ba_def_type>  ba_def_type
%type <ba_def>       ba_def
%type <ba_def_def>   ba_def_def ba_def_def_data
%type <sg_type>      sg_type
%type <sg_range>     sg_range
%type <sg>           sg
%type <sgs>          sgs
%type <bo>           bo

%%

main   : any
       | main any
       ;

version : VERSION QUOTED_STRING EOL { Console.WriteLine("version: {0}", $2); }
        ;

namespace       : NS ':' EOL namespace_lines { Console.WriteLine("namespace"); }
                ;

namespace_line  : TAB keyword EOL
                { Console.WriteLine("namespace_line"); }
                ;

namespace_lines : namespace_line
                | namespace_lines namespace_line
				;

bs              : BS ':' EOL
                ;

bu              : BU ':' identifiers EOL
                ;

val_table       : VAL_TABLE IDENTIFIER NUMBER QUOTED_STRING NUMBER QUOTED_STRING ';'
				{ Console.WriteLine("val_table"); }
				;

sg_range        : '[' NUMBER '|' NUMBER ']'
					{ $$ = new SignalRange($2, $4); }
                ;

sg_type    : '@' NUMBER '+'
					{
						if ($2 == 0) {
							$$ = SignalType.SIGNED_MOTOROLA;
						} else {
							$$ = SignalType.SIGNED_INTEL;
						}
					}
				| '@' NUMBER '-'
					{
						if ($2 == 0) {
							$$ = SignalType.UNSIGNED_MOTOROLA;
						} else {
							$$ = SignalType.UNSIGNED_INTEL;
						}
					}

                ;

sg              : SG IDENTIFIER ':' NUMBER '|' NUMBER sg_type '(' NUMBER ',' NUMBER ')' sg_range QUOTED_STRING identifier_list EOL
					{
						$$ = new Signal($2, (uint)$4, (uint)$6, $7, $13, $14, $15);
					}
                ;

sgs             : /* empty */
					{ $$ = new List<Signal>(); }
                | sgs sg
					{ $$.Add($2); }
				;

bo              : BO NUMBER IDENTIFIER ':' NUMBER IDENTIFIER EOL sgs
					{
						$$ = new Message((uint)$2, $3, (uint)$5, $6, $8);
						m_messages.Add($$);
					}
                ;

cm              : CM SG NUMBER IDENTIFIER QUOTED_STRING ';' EOL
                ;

ba_def_object   : SG
					{ $$ = "SG"; }
                | BO
					{ $$ = "BO"; }
				| BU
					{ $$ = "BU"; }
				| /* empty */
					{ $$ = ""; }
				;

string_list     : QUOTED_STRING
					{ $$ = new List<string>(); $$.Add($1); }
                | string_list ',' QUOTED_STRING
					{ $$.Add($3); }
				;

identifier_list : IDENTIFIER
					{ $$ = new List<string>(); $$.Add($1); }
                | identifier_list ',' IDENTIFIER
					{ $$.Add($3); }
				;

ba_def_type     : FLOAT NUMBER NUMBER
					{ $$ = new AttributeLimitsNumeric<float>($2, $3); }
                | ENUM  string_list
					{ $$ = new AttributeLimitsEnum($2); }
				| INT   NUMBER NUMBER
					{ $$ = new AttributeLimitsNumeric<Int64>($2, $3); }
				| STRING
					{ $$ = new AttributeLimitsString(); }
				;

ba_def          : BA_DEF ba_def_object QUOTED_STRING ba_def_type ';' EOL
					{
						$$ = new AttributeDefinition($2, $3, $4);
						m_attribute_definitions.Add($$);
					}
                ;

ba_def_def_data : QUOTED_STRING NUMBER
					{ $$ = new AttributeDefault<float>($1, $2); }
                | QUOTED_STRING QUOTED_STRING
					{ $$ = new AttributeDefault<string>($1, $2); }
                ;

ba_def_def      : BA_DEF_DEF ba_def_def_data ';' EOL
					{ m_attribute_defaults.Add($2); }
                ;

ba_value        : QUOTED_STRING
                | BU IDENTIFIER NUMBER
				| BO NUMBER NUMBER
				| SG NUMBER IDENTIFIER NUMBER
				;

ba              : BA QUOTED_STRING ba_value ';' EOL
                ;

any    : version
	   | namespace
	   | bs
	   | bu
	   | val_table
	   | bo
	   | cm
	   | ba_def
	   | ba_def_def
	   | ba
	   | EOL
	   ;

keyword  : BO
         | NS
         | BS
         | BU
         | VAL_TABLE
         | SG
         | CM
         | BA
         | BA_DEF
         | BA_DEF_DEF
         | VERSION
		 | IDENTIFIER
		 ;

identifiers : /* empty */
            | identifiers IDENTIFIER
			;

%%