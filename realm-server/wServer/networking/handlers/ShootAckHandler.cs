using wServer.networking.packets;
using wServer.networking.packets.incoming;

namespace wServer.networking.handlers
{
    class ShootAckHandler : PacketHandlerBase<ShootAck>
    {
        public override PacketId GetPacketId => PacketId.SHOOTACK;

        protected override void HandlePacket(Client client, ShootAck packet)
        {
            //client.Player.ShootAckReceived();
        }
    }
}
