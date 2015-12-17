# Scrimmage

Scrimmage servers are designed to help train operators and test tools for attack-defend style Capture the Flag competitions (CTF). This server hosts the [DEFCON 22](https://www.defcon.org/html/defcon-22/dc-22-ctf.html) services and their respective flags. Offensive tools help collect these flags from other team servers. Defensive tools help prevent flag collection.

## Deployment

This server is designed for easy install on Ubuntu 14.04 x64 using the following commands:

    # instal git to download repository
    apt-get update && apt-get -y install git

	# install scrimmage config
	cd /
	git init
	git remote add origin git@github.com:samuraictf/scrimmage-dc22-gamebox.git
	git fetch --quiet origin master
	git checkout -f -t origin/master
	/root/setup.sh

### Scoring

Scoring mirrors DEFCON 22 rules. Each round there are `$n_teams-1` points per service at stake. Rounds are 5 minutes long. Points are zero-sum.

#### Scoring

Flags are located in `/home/$SERVICE/flag`. If Service A on Team A is exploited, Team A will lose `$n_teams-1` points from Service A's pool of points. These points are distributed equally among all teams who captured Team A's Service A this round. For example, if 3 (of 7) teams capture Team A's "atmail" service flag this round they will each receive 2 points ((7-1) / 3).

#### Service Level Assessment (SLA)

Service Level Assessments regularly verify that services are active and behaving correctly. If Service A on Team A fails such a check, Team A will lose `$n_teams-1` points from Service A's pool of points. These points are distributed equally among all teams that passed the SLA check on Service A this round. For example, if only 1 (of 7) teams fails SLA on the "atmail" service then all other teams will receive 1 point ((7-1)/6).

### PCAPs

A packet capture is made available on the gamebox every 5 minutes at `/tmp/latest.pcap`. It is your job to roll the pcaps together.

### Services

 Port | Name
------|-----------
10001 | eliza
10002 | imapX
10003 | justify
10004 | wdub
10005 | bash
10006 | exploitme
10007 | patchme
10008 | replayme
10009 | babycmd
10010 | babyecho
10011 | r0pbaby
10012 | atmail
10013 | avoir
10014 | bookworm
10015 | lonetuna_v1
10016 | lonetuna_v2
10017 | reeses
10018 | trouver
