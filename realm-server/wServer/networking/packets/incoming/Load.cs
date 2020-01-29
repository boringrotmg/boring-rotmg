using common;

namespace wServer.networking.packets.incoming
{
    public class Load : IncomingMessage
    {
        public int CharId { get; set; }

        public override PacketId GetPacketId => PacketId.LOAD;
        public override Packet CreateInstance() { return new Load(); }

        protected override void Read(NReader rdr)
        {
            CharId = rdr.ReadInt32();
        }

        protected override void Write(NWriter wtr)
        {
            wtr.Write(CharId);
        }
    }
}
