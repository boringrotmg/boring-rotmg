using wServer.networking.packets;
using wServer.networking.packets.incoming;

namespace wServer.networking.handlers
{
    class OtherHitHandler : PacketHandlerBase<OtherHit>
    {
        public override PacketId GetPacketId => PacketId.OTHERHIT;

        protected override void HandlePacket(Client client, OtherHit packet)
        {
        }
    }
}
