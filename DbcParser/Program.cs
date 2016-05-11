using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace DbcParser
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var file = new FileStream("config_3.dbc", FileMode.Open))
            {
                var scanner = new VectorDbcScanner(file);
                var parser = new VectorDbcParser(scanner);

                if (parser.Parse()) {

                    Console.WriteLine("Attribute Defaults");
                    foreach (var v in parser.m_attribute_defaults)
                        Console.WriteLine(v.ToString());

                    Console.WriteLine("Attribute Definitions");
                    foreach (var v in parser.m_attribute_definitions)
                        Console.WriteLine(v.ToString());

                    Console.WriteLine("Messages");
                    foreach (var v in parser.m_messages)
                        Console.WriteLine(v.ToString());

                    Environment.ExitCode = 0;
                } else {
                    Console.WriteLine("Line {0} {1}", scanner.line, scanner.yylval.s);
                    Environment.ExitCode = 1;
                }
            }
#if DEBUG
            Console.WriteLine("Press enter to close...");
            Console.ReadLine();
#endif
        }
    }
}
