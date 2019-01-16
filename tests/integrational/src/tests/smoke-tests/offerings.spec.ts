import { expect } from 'chai';
import 'mocha';

import { Until } from '../../utils/until';

import {
  generateOffering,
  generateSomeOfferings
} from '../../utils/offerings';

import { Offering, OfferStatus } from '../../typings/offerings';
import { PaginatedResponse } from '../../typings/paginatedResponse';
import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

import { getItFunc } from "../../utils/test-utils";

export const offerings: TestModel = {
  name: 'offerings',
  scope: TestScope.BOTH,
  testFn: (settings: TestInputSettings) => {
    const {
      agentWs, clientWs,
      allowedScope
    } = settings;

    const until = Until(agentWs);
    const clientUntil = Until(clientWs);

    const agentIt = getItFunc({scope: TestScope.AGENT}, allowedScope);
    const clientIt = getItFunc({scope: TestScope.CLIENT}, allowedScope);

    describe('offerings', () => {
      let offeringId: string;
      let offeringHash: string;
      let offeringToDeleteId: string;

      describe('create offering', () => {
        agentIt('should create an offering', async () => {
          const productId = (await agentWs.getProducts())[0].id;
          const accounts = await agentWs.getAccounts();
          const agentWsId = accounts[0].id;

          offeringId = await agentWs.createOffering(
            generateOffering(productId, agentWsId, 'Main Service')
          ) as string;

          expect(offeringId).to.not.be.undefined;
        });

        agentIt('should publish already created offering', async function () {
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime*4);

          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          await agentWs.changeOfferingStatus(offeringId, 'publish', gasPrice);

          await until
            .object('offering')
            .withId(offeringId)
            .prop('status')
            .becomes(OfferStatus.registered);

          const offering = await agentWs.getOffering(offeringId);
          offeringHash = offering.hash;

          expect(offering.status).to.equal(OfferStatus.registered)
        });

        agentIt('should create some additional offerings', async function() {
          const productId = (await agentWs.getProducts())[0].id;
          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          const accounts = await agentWs.getAccounts();
          const agentWsId = accounts[0].id;

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          for (let offering of generateSomeOfferings(productId, agentWsId)) {
            const tmpOfferingId = await agentWs.createOffering(offering);

            await agentWs.changeOfferingStatus(
              tmpOfferingId, 'publish', gasPrice
            );

            await until
              .object('offering')
              .withId(tmpOfferingId)
              .prop('status')
              .becomes(OfferStatus.registered);
          }
        });

        agentIt('should contain already created offerings for agentWs', async () => {
          const productId = (await agentWs.getProducts())[0].id;
          const offerings = await agentWs.getAgentOfferings(
            productId,
            OfferStatus.registered,
            0, 10
          ) as PaginatedResponse<Array<Offering>>;

          const offeringForCheck = (offerings.items.filter(offering => offering.id === offeringId))[0];

          expect(offerings.totalItems).to.equal(4);
          expect(offeringForCheck).to.have.deep.property('id', offeringId);

          offeringToDeleteId = offerings.items[1].id;
        });
      });

      describe('popup offering', () => {
        clientIt('first offering should be last for client', async () => {
          const accounts = await agentWs.getAccounts();
          const agentEthAddr = accounts[0].ethAddr;

          const offerings = await clientWs.getClientOfferings(
            agentEthAddr,
            100000,
            200000,
            ['KG']
          );

          expect((offerings.items[offerings.totalItems - 1]).hash).to.equal(offeringHash);
        });

        agentIt('should popup an offering', async function() {
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 12);

          const blockNumberCreated = (await agentWs.getOffering(offeringId) as Offering).blockNumberUpdated;

          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          await agentWs.changeOfferingStatus(
            offeringId,
            'popup',
            gasPrice
          );

          await until
            .object('offering')
            .withId(offeringId)
            .prop('status')
            .becomes(OfferStatus.popped_up);

          const blockNumberUpdated = (await agentWs.getOffering(offeringId) as Offering).blockNumberUpdated;

          expect(blockNumberUpdated > blockNumberCreated).to.be.true;
        });

        clientIt('after popup the offering should be on top', async function () {
          const accounts = await agentWs.getAccounts();
          const agentEthAddr = accounts[0].ethAddr;

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          const clientOfferingId = (await clientWs.getObjectByHash('offering', offeringHash) as Offering).id;

          await clientUntil
            .object('offering')
            .withId(clientOfferingId)
            .prop('status')
            .becomes(OfferStatus.popped_up);

          const offerings = await clientWs.getClientOfferings(
              agentEthAddr,
              100000,
              200000,
              ['KG']
          );

          expect(offerings.totalItems).to.equal(4);
          expect(offerings.items[0].hash).to.equal(offeringHash);
        });
      });

      describe('delete offering', () => {
        agentIt('should delete an offering', async function(){
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          await agentWs.changeOfferingStatus(
            offeringToDeleteId, 'deactivate', gasPrice
          );

          await until
            .object('offering')
            .withId(offeringToDeleteId)
            .prop('status')
            .becomes(OfferStatus.removed);

          const offering = await agentWs.getOffering(offeringToDeleteId);

          expect(offering.status).to.equal(OfferStatus.removed)
        });
      });
    });
  }
};
