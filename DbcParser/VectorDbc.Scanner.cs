using System;
using System.Collections.Generic;
using System.Text;

namespace DbcParser
{
    internal partial class VectorDbcScanner
    {

        void GetNumber()
        {
            yylval.s = yytext;
            yylval.n = Int64.Parse(yytext);
        }

		public override void yyerror(string format, params object[] args)
		{
			base.yyerror(format, args);
			Console.WriteLine(format, args);
			Console.WriteLine();
		}
    }
}
