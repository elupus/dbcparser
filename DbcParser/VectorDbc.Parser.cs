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

    public interface AttributeDefault
    {

    }

    public struct AttributeDefault<T> : AttributeDefault
    {
        public AttributeDefault(string name, T value) {
            this.value = value;
        }
        T value;
    }
    public enum SignalType
    {
        UNSIGNED_MOTOROLA,
        UNSIGNED_INTEL,
        SIGNED_MOTOROLA,
        SIGNED_INTEL,
    }

    public struct SignalRange
    {
        public SignalRange(Int64 minumum, Int64 maximum) {
            this.minumum = minumum;
            this.maximum = maximum;
        }

        Int64 minumum;
        Int64 maximum;
    }

    public struct Signal
    {

        public Signal(String name, uint len, uint offset, SignalType type, SignalRange range, String unit, List<String> receivers) {
            this.name      = name;
            this.len       = len;
            this.offset    = offset;
            this.type      = type;
            this.range     = range;
            this.receivers = receivers;
        }

        String       name;
        uint         len;
        uint         offset;
        SignalType   type;
        SignalRange  range;
        List<String> receivers;
    }

    public struct Message
    {
        public Message(uint id, String name, uint len, String source, List<Signal> signals) {
            this.id      = id;
            this.len     = len;
            this.name    = name;
            this.source  = source;
            this.signals = signals;
        }

        public override string ToString() {
            return String.Format("Message({0}, {1}, {2}, {3}, {4})", id, name, len, source, signals);
        }

        uint         id;
        uint         len;
        String       name;
        String       source;
        List<Signal> signals;
    }

    internal partial class VectorDbcParser
    {
        public List<AttributeDefault>    m_attribute_defaults = new List<AttributeDefault>();
        public List<AttributeDefinition> m_attribute_definitions = new List<AttributeDefinition>();
        public List<Message>             m_messages = new List<Message>();

        public VectorDbcParser(VectorDbcScanner scanner) : base(scanner) { }
    }
}
