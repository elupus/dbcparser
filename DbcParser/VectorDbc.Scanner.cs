using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace DbcParser
{
    internal partial class VectorDbcScanner
    {

        void GetNumber()
        {
            yylval.s = yytext;
            yylval.n = decimal.Parse(yytext, System.Globalization.NumberStyles.Float, CultureInfo.InvariantCulture);
        }

		public override void yyerror(string format, params object[] args)
		{
			base.yyerror(format, args);
			Console.WriteLine(format, args);
			Console.WriteLine();
		}
    }
}
