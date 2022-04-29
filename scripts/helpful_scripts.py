from brownie import network, accounts, config


def get_account():
    match network.show_active():
        case "development":
            return accounts[0]
        case _:
            private_key = config["wallets"]["from_key"]
            return accounts.add(private_key)