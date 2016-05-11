using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace DbcParser
{
    public interface AttributeLimits
    {
    }

    public struct AttributeLimitsNumeric<T> : AttributeLimits
    {
        public AttributeLimitsNumeric(T minimum, T maximum) {
            this.minimum = minimum;
            this.maximum = maximum;
        }
        T minimum;
        T maximum;
        public override string ToString() {
            return string.Format("AttributeLimitsNumeric({0}, {1})", minimum, maximum);
        }
    }

    public struct AttributeLimitsEnum : AttributeLimits
    {
        public AttributeLimitsEnum(List<String> values) {
            this.values = values;
        }
        public override string ToString() {
            return string.Format("AttributeLimitsEnum({0})", String.Join(";", values));
        }
        List<String> values;
    }

    public struct AttributeLimitsString : AttributeLimits
    {
    }

    public struct AttributeDefinition
    {
        public AttributeDefinition(string type, string name, AttributeLimits limits) {
            this.type = type;
            this.name = name;
            this.limits = limits;
        }
        string type;
        string name;
        AttributeLimits limits;

        public override string ToString() {
            return String.Format("AttribugeDefinition({0}, {1}, {2})", type, name, limits.ToString());
        }
    }

    public interface AttributeValue
    {
        string name { get; set; }
    }

    public struct AttributeValue<T> : AttributeValue
    {
        public AttributeValue(string name, T value) {
            this.m_name  = name;
            this.value = value;
        }
        public string name {
            get { return m_name; }
            set { m_name = value; }
        }
        private string m_name;
        public T      value;

        public override string ToString() {
            return String.Format("AttributeValue({0}, {0})", m_name, value);
        }
    }

    public enum SignalType
    {
        UNSIGNED_MOTOROLA,
        UNSIGNED_INTEL,
        SIGNED_MOTOROLA,
        SIGNED_INTEL,
        DOUBLE,
    }

    public struct SignalRange
    {
        public SignalRange(decimal minumum, decimal maximum) {
            this.minumum = minumum;
            this.maximum = maximum;
        }

        decimal minumum;
        decimal maximum;

        public override string ToString() {
            return String.Format("SignalRange({0}, {0})", minumum, maximum);
        }
    }

    public class Signal
    {

        public Signal(String name, uint len, uint offset, SignalType type, SignalRange range, String unit, List<String> receivers) {
            this.name = name;
            this.len = len;
            this.offset = offset;
            this.comment = "";
            this.type = type;
            this.range = range;
            this.receivers = receivers;
            this.attributes = new Dictionary<string, AttributeValue>();
            this.values = new Dictionary<decimal, string>();
        }

        public string name;
        public uint len;
        public uint offset;
        public string comment;
        public SignalType type;
        public SignalRange range;
        public List<String> receivers;
        public Dictionary<string, AttributeValue> attributes;
        public Dictionary<decimal, string> values;

        public override string ToString() {
            return String.Format("Signal({0}, {1}, {2}, {3}, {4}, {5}, [{6}], [{7}])", name, len, offset, comment, type, range, String.Join(",", receivers), String.Join(",", attributes.Values));
        }
    }

    public class Message
    {
        public Message(uint id, string name, uint len, string source, List<Signal> signals) {
            this.id      = id;
            this.len     = len;
            this.name    = name;
            this.source  = source;
            this.comment = "";
            this.signals = new Dictionary<string, Signal>();
            foreach (var s in signals) {
                this.signals.Add(s.name, s);
            }
            this.attributes = new Dictionary<string, AttributeValue>();
        }

        public override string ToString() {
            return String.Format("Message({0}, {1}, {2}, {3}, [{4}])", id, name, len, source, String.Join(",", signals.Values));
        }

        public uint         id;
        public uint         len;
        public string       name;
        public string       source;
        public string       comment;
        public Dictionary<string, Signal> signals;
        public Dictionary<string, AttributeValue> attributes;
    }

    public class Node
    {
        public Node(string name) {
            this.name = name;
            this.comment = "";
            this.attributes = new Dictionary<string, AttributeValue>();
        }
        public string name;
        public string comment;
        public Dictionary<string, AttributeValue> attributes;
    }

    public class Network
    {
        public Network(string name)
        {
            this.name = name;
            this.attributes = new Dictionary<string, AttributeValue>();
        }
        public string name;
        public Dictionary<string, AttributeValue> attributes;
    }

    public class ValueTable
    {
        public ValueTable(string name, Dictionary<decimal, string> values) 
        {
            this.name   = name;
            this.values = values;
        }
        public string name;
        public Dictionary<decimal, string> values;
    }

    internal partial class VectorDbcParser
    {
        public List<AttributeValue>      m_attribute_defaults = new List<AttributeValue>();
        public List<AttributeDefinition> m_attribute_definitions = new List<AttributeDefinition>();
        public Dictionary<uint, Message> m_messages = new Dictionary<uint, Message>();
        public Dictionary<string, Node>  m_nodes = new Dictionary<string, Node>();
        public Network                   m_network = new Network("");
        public Dictionary<string, ValueTable> m_valuetables = new Dictionary<string, ValueTable>();

        public VectorDbcParser(VectorDbcScanner scanner) : base(scanner)
        {
            m_nodes.Add("Vector__XXX", new Node("Vector__XXX"));
        }
    }
}
