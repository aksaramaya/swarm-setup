CONFIG_DIRS := config
BIN := bin
SRC := $(PWD)

.PHONY: all clean bootstrap master slave flush consul info frak repo

all: bootstrap

bootstrap:
	echo "Setup Repository..."
	bash $(BIN)/bootstrap
	yum install -y docker-engine
	systemctl stop docker
	systemctl disable docker
	cp $(CONFIG_DIRS)/docker-swarm-am.service /lib/systemd/system
	chmod 644 /lib/systemd/system/docker-swarm-am.service
	systemctl enable docker-swarm-am
	systemctl start docker-swarm-am

master:
	bash $(BIN)/master $(SRC)

slave:
	bash $(BIN)/slave $(SRC)

consul:
	docker run -d -p 8500:8500 --name=consul progrium/consul -server -bootstrap

flush:
	bash $(BIN)/docker-flush

info:
	docker -H :4000 info

frak:
	bash $(BIN)/frak $(IP)

clean:
	yum remove -y docker-engine
	systemctl disable docker-swarm-am
	systemctl stop docker-swarm-am
	rm -rf /lib/systemd/system/docker-swarm-am.service

repo:
	echo "Setup Repository..."
	bash $(BIN)/bootstrap
	yum install -y docker-engine
	systemctl enable docker
	systemctl start docker
