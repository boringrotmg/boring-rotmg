using System;
using System.Collections.Generic;
using System.Linq;
using common;
using common.resources;
using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.networking.packets.incoming.market;
using wServer.networking.packets.outgoing;
using wServer.networking.packets.outgoing.market;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.networking.handlers.market
{
    class MarketBuyHandler : PacketHandlerBase<MarketBuy>
    {
        public override PacketId GetPacketId => PacketId.MARKET_BUY;

        protected override void HandlePacket(Client client, MarketBuy packet)
        {
            client.Manager.Logic.AddPendingAction(t => 
            {
                var player = client.Player;
                if (player == null || IsTest(client))
                {
                    return;
                }

                DbMarketData data = client.Manager.Database.GetMarketData(packet.Id);
                if (data == null) /* Make sure the item exist before buying it */
                {
                    client.SendPacket(new MarketBuyResult
                    {
                        Code = MarketBuyResult.ITEM_DOESNT_EXIST,
                        Description = "Item was taken down or bought."
                    });
                    return;
                }

                if (data.SellerId == player.AccountId) /* If we somehow try to buy our own item */
                {
                    client.SendPacket(new MarketBuyResult
                    {
                        Code = MarketBuyResult.MY_ITEM,
                        Description = "You cannot buy your own item."
                    });
                    return;
                }

                if (player.GetCurrency(data.Currency) < data.Price) /* Make sure we have enough to buy the item */
                {
                    client.SendPacket(new MarketBuyResult
                    {
                        Code = MarketBuyResult.CANT_AFFORD,
                        Description = "You cannot afford this item."
                    });
                    return;
                }

                /* Update the sellers currency */
                var sellerAccount = player.Manager.Database.GetAccount(data.SellerId); 
                player.Manager.Database.UpdateFame(sellerAccount, data.Price);
                player.Manager.Database.RemoveMarketData(sellerAccount, data.Id);

                Item item = player.Manager.Resources.GameData.Items[data.ItemType];

                string currency = data.Currency == CurrencyType.Fame ? "fame" : "gold";

                /* Incase he is online, we let him know someone bought his item */
                var seller = player.Manager.Clients.Keys.SingleOrDefault(_ => _.Account != null && _.Account.AccountId == data.SellerId);
                if (seller != null)
                {
                    seller.Player.SendInfo($"{player.Name} has just bought your {item.ObjectId} for {data.Price} {currency}!");

                    // Dynamically update his fame if hes online.
                    seller.Player.CurrentFame = sellerAccount.Fame;
                }

                /* Update the buyers currency */
                player.Manager.Database.UpdateFame(client.Account, -data.Price);
                player.CurrentFame = player.Client.Account.Fame;
                player.Manager.Database.AddGift(client.Account, data.ItemType);
                
                client.SendPacket(new MarketBuyResult
                {
                    Code = -1,
                    Description = $"Successfully bought {item.ObjectId} for {data.Price} {currency}!",
                    OfferId = data.Id /* We send back the ID we bought, so we can remove it from the list */
                });
            });
        }
    }
}
