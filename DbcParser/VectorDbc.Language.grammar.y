%namespace DbcParser
%partial
%parsertype VectorDbcParser
%visibility internal
%tokentype Token

%union { 
            public decimal n; 
            public string s; 
            public List<string> sl;
            public Tuple<decimal, string> val_entry;
            public Dictionary<decimal, string> val_list;
            public AttributeLimits     ba_def_type;
            public AttributeDefinition ba_def;
            public AttributeValue      av;
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
%token SIG_VALTYPE
%token VAL
%token EV

%token FLOAT
%token ENUM
%token INT
%token STRING

%type <s>            ba_def_object
%type <sl>           string_list identifier_list identifiers
%type <ba_def_type>  ba_def_type
%type <ba_def>       ba_def
%type <av>           ba_def_def ba_def_def_data ba ba_value
%type <sg_type>      sg_type
%type <sg_range>     sg_range
%type <sg>           sg
%type <sgs>          sgs
%type <bo>           bo
%type <val_entry>    val_entry
%type <val_list>     val_list val

%%

main            : any
                | main any
                ;

version         : VERSION QUOTED_STRING EOL
                ;

namespace       : NS ':' EOL namespace_lines
                ;

namespace_line  : TAB keyword EOL
                ;

namespace_lines :   namespace_line
                |   namespace_lines namespace_line
                ;

bs              :   BS ':' EOL
                ;

bu              :   BU ':' identifiers EOL {
                        foreach(var n in $3) {
                            m_nodes.Add(n, new Node(n));
                        }
                    }
                ;

sg_range        :   '[' NUMBER '|' NUMBER ']' {
                        $$ = new SignalRange($2, $4);
                    }
                ;

sg_type         :   '@' NUMBER '+' {
                        if ($2 == 0) {
                            $$ = SignalType.SIGNED_MOTOROLA;
                        } else {
                            $$ = SignalType.SIGNED_INTEL;
                        }
                    }
                |   '@' NUMBER '-' {
                        if ($2 == 0) {
                            $$ = SignalType.UNSIGNED_MOTOROLA;
                        } else {
                            $$ = SignalType.UNSIGNED_INTEL;
                        }
                    }

                ;

sg              :   SG IDENTIFIER ':' NUMBER '|' NUMBER sg_type '(' NUMBER ',' NUMBER ')' sg_range QUOTED_STRING identifier_list EOL  {
                        $$ = new Signal($2, (uint)$4, (uint)$6, $7, $13, $14, $15);
                    }
                ;

sgs             :   /* empty */ {
                        $$ = new List<Signal>();
                    }

                |   sgs sg {   
                        $$ = $1;
                        $$.Add($2);
                    }
                ;

bo              :   BO NUMBER IDENTIFIER ':' NUMBER IDENTIFIER EOL sgs {
                        $$ = new Message((uint)$2, $3, (uint)$5, $6, $8);
                        m_messages[$$.id] = $$;
                    }
                ;

cm              :   CM SG NUMBER IDENTIFIER QUOTED_STRING ';' EOL {
                        m_messages[(uint)$3].signals[$4].comment = $5;
                    }
                |   CM BO NUMBER QUOTED_STRING ';' EOL {
                        m_messages[(uint)$3].comment = $4;
                    }
                |   CM BU IDENTIFIER QUOTED_STRING ';' EOL {
                        m_nodes[$3].comment = $4;
                    }
                ;

ba_def_object   :   SG {
                        $$ = "SG";
                    }
                |   BO {
                        $$ = "BO";
                    }
                |   BU {
                        $$ = "BU";
                    }
                |   /* empty */ {
                        $$ = "";
                    }
                ;

string_list     :   QUOTED_STRING {
                        $$ = new List<string>();
                        $$.Add($1);
                    }
                |   string_list ',' QUOTED_STRING {
                        $$ = $1;
                        $$.Add($3);
                    }
                ;

identifier_list :   IDENTIFIER {
                        $$ = new List<string>();
                        $$.Add($1);
                    }

                |   identifier_list ',' IDENTIFIER {   
                        $$ = $1;
                        $$.Add($3);
                    }
                ;

identifiers     :   /* empty */ {
                        $$ = new List<string>();
                    }
                |   identifiers IDENTIFIER {
                        $$.Add($2);
                    }
                ;

ba_def_type     :   FLOAT NUMBER NUMBER {
                        $$ = new AttributeLimitsNumeric<decimal>($2, $3);
                    }

                |   ENUM  string_list {
                        $$ = new AttributeLimitsEnum($2);
                    }
                |   INT   NUMBER NUMBER {
                        $$ = new AttributeLimitsNumeric<decimal>($2, $3);
                    }
                |   STRING {
                        $$ = new AttributeLimitsString();
                    }
                ;

ba_def          :   BA_DEF ba_def_object QUOTED_STRING ba_def_type ';' EOL {
                        $$ = new AttributeDefinition($2, $3, $4);
                        m_attribute_definitions.Add($$);
                    }
                ;

ba_def_def_data :   QUOTED_STRING NUMBER {
                        $$ = new AttributeValue<decimal>($1, $2);
                    }
                |   QUOTED_STRING QUOTED_STRING {
                        $$ = new AttributeValue<string>($1, $2);
                    }
                ;

ba_def_def      :   BA_DEF_DEF ba_def_def_data ';' EOL {
                        m_attribute_defaults.Add($2);
                    }
                ;

ba_value        :   QUOTED_STRING {
                        $$ = new AttributeValue<string>("", $1);
                    }
                |   NUMBER {
                        $$ = new AttributeValue<decimal>("", $1);
                    }
                ;

ba              :   BA QUOTED_STRING ba_value ';' EOL {
                        $$ = $3;
                        $$.name = $2;
                        m_network.attributes.Add($$.name, $$);
                    }
                |   BA QUOTED_STRING BU IDENTIFIER ba_value ';' EOL {
                        $$ = $5;
                        $$.name = $2;
                        m_nodes[$4].attributes.Add($$.name, $$);
                    }
                |   BA QUOTED_STRING BO NUMBER ba_value ';' EOL {
                        $$ = $5;
                        $$.name = $2;
                        m_messages[(uint)$4].attributes.Add($$.name, $$);
                    }
                |   BA QUOTED_STRING SG NUMBER IDENTIFIER ba_value ';' EOL {    
                        $$ = $6;
                        $$.name = $2;
                        m_messages[(uint)$4].signals[$5].attributes.Add($$.name, $$);
                    }
                ;

val_entry       :   NUMBER QUOTED_STRING {
                        $$ = new Tuple<decimal, string>($1, $2);
                    }
                ;

val_list        :   /* empty */ {
                        $$ = new Dictionary<decimal, string>();
                    }
                |   val_list val_entry {
                        $$ = $1;
                        $$.Add($2.Item1, $2.Item2);
                    }
                ;

val             :   VAL NUMBER IDENTIFIER val_list ';' EOL {
                        $$ = $4;
                        m_messages[(uint)$2].signals[$3].values = $4;
                    }
                ;

val_table       :   VAL_TABLE IDENTIFIER val_list ';' EOL {
                        m_valuetables[$2] = new ValueTable($2, $3);
                    }
                ;

ev              :   EV IDENTIFIER ':' NUMBER sg_range QUOTED_STRING NUMBER NUMBER IDENTIFIER IDENTIFIER ';' EOL {
                    }
                ;

sig_valtype     :   SIG_VALTYPE NUMBER IDENTIFIER ':' NUMBER ';' EOL {
                        if ($5 == 1) {
                            m_messages[(uint)$2].signals[$3].type = SignalType.DOUBLE;
                        } else {
                            throw new Exception("Unknown value type");
                        }
                    }
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
       | val
       | val_table
       | ev
       | sig_valtype
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
         | SIG_VALTYPE
         | VERSION
         | IDENTIFIER
         | VAL
         ;


%%