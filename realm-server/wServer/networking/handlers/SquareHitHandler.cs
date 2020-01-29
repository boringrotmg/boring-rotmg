using wServer.networking.packets;
using wServer.networking.packets.incoming;

namespace wServer.networking.handlers
{
    class SquareHitHandler : PacketHandlerBase<SquareHit>
    {
        public override PacketId GetPacketId => PacketId.SQUAREHIT;

        protected override void HandlePacket(Client client, SquareHit packet)
        {
        }
    }
}
