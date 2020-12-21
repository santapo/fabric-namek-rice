#!/bin/bash

source scriptUtils.sh

function createProducer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/producer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/producer.example.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7055 --caname ca-producer --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-producer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-producer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-producer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-producer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-producer --id.name producer --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-producer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-producer --id.name produceradmin --id.secret produceradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/producer.example.com/peers
  mkdir -p organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7055 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/msp --csr.hosts peer0.producer.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7055 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls --enrollment.profile tls --csr.hosts peer0.producer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/producer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/producer.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/producer.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/producer.example.com/tlsca/tlsca.producer.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/producer.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/producer.example.com/peers/peer0.producer.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/producer.example.com/ca/ca.producer.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/producer.example.com/users
  mkdir -p organizations/peerOrganizations/producer.example.com/users/User1@producer.example.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7055 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.example.com/users/User1@producer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/producer.example.com/users/User1@producer.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/producer.example.com/users/Admin@producer.example.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://produceradmin:produceradminpw@localhost:7055 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.example.com/users/Admin@producer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/producer.example.com/users/Admin@producer.example.com/msp/config.yaml

}

function createManufacturer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.example.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7056 --caname ca-manufacturer --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7056-ca-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name manufactureradmin --id.secret manufactureradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/manufacturer.example.com/peers
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7056 --caname ca-manufacturer -M ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp --csr.hosts peer0.manufacturer.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7056 --caname ca-manufacturer -M ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls --enrollment.profile tls --csr.hosts peer0.manufacturer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/manufacturer.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/manufacturer.example.com/ca/ca.manufacturer.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/manufacturer.example.com/users
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7056 --caname ca-manufacturer -M ${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:7056 --caname ca-manufacturer -M ${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp/config.yaml

}

function createDeliverer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/deliverer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/deliverer.example.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7057 --caname ca-deliverer --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7057-ca-deliverer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7057-ca-deliverer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7057-ca-deliverer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7057-ca-deliverer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/deliverer.example.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-deliverer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-deliverer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-deliverer --id.name delivereradmin --id.secret delivereradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/deliverer.example.com/peers
  mkdir -p organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7057 --caname ca-deliverer -M ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/msp --csr.hosts peer0.deliverer.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7057 --caname ca-deliverer -M ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls --enrollment.profile tls --csr.hosts peer0.deliverer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/deliverer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/deliverer.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/deliverer.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/deliverer.example.com/tlsca/tlsca.deliverer.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/deliverer.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/peers/peer0.deliverer.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/deliverer.example.com/ca/ca.deliverer.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/deliverer.example.com/users
  mkdir -p organizations/peerOrganizations/deliverer.example.com/users/User1@deliverer.example.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7057 --caname ca-deliverer -M ${PWD}/organizations/peerOrganizations/deliverer.example.com/users/User1@deliverer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/deliverer.example.com/users/User1@deliverer.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/deliverer.example.com/users/Admin@deliverer.example.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://delivereradmin:delivereradminpw@localhost:7057 --caname ca-deliverer -M ${PWD}/organizations/peerOrganizations/deliverer.example.com/users/Admin@deliverer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/deliverer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/deliverer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/deliverer.example.com/users/Admin@deliverer.example.com/msp/config.yaml

}

function createRetailer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/retailer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/retailer.example.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7058 --caname ca-retailer --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7058-ca-retailer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7058-ca-retailer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7058-ca-retailer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7058-ca-retailer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/retailer.example.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-retailer --id.name retaileradmin --id.secret retaileradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/retailer.example.com/peers
  mkdir -p organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7058 --caname ca-retailer -M ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/msp --csr.hosts peer0.retailer.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7058 --caname ca-retailer -M ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls --enrollment.profile tls --csr.hosts peer0.retailer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/retailer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/retailer.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/retailer.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/retailer.example.com/tlsca/tlsca.retailer.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/retailer.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/peers/peer0.retailer.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/retailer.example.com/ca/ca.retailer.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/retailer.example.com/users
  mkdir -p organizations/peerOrganizations/retailer.example.com/users/User1@retailer.example.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7058 --caname ca-retailer -M ${PWD}/organizations/peerOrganizations/retailer.example.com/users/User1@retailer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/retailer.example.com/users/User1@retailer.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/retailer.example.com/users/Admin@retailer.example.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://retaileradmin:retaileradminpw@localhost:7058 --caname ca-retailer -M ${PWD}/organizations/peerOrganizations/retailer.example.com/users/Admin@retailer.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/retailer.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/retailer.example.com/users/Admin@retailer.example.com/msp/config.yaml

}

function createOrderer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7059 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7059-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7059-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7059-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7059-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/example.com/orderers
  mkdir -p organizations/ordererOrganizations/example.com/orderers/example.com

  mkdir -p organizations/ordererOrganizations/example.com/orderers/orderer.example.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7059 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7059 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p organizations/ordererOrganizations/example.com/users
  mkdir -p organizations/ordererOrganizations/example.com/users/Admin@example.com

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:7059 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

}
