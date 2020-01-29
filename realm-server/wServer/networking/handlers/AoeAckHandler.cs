using wServer.networking.packets;
using wServer.networking.packets.incoming;

namespace wServer.networking.handlers
{
    class AoeAckHandler : PacketHandlerBase<AoeAck>
    {
        public override PacketId GetPacketId => PacketId.AOEACK;

        protected override void HandlePacket(Client client, AoeAck packet)
        {
            //TODO: implement something
        }
    }
}
