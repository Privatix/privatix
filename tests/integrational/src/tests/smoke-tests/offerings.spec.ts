import { expect } from 'chai';
import 'mocha';

import { TemplateType } from '../../typings/templates';
import { Until } from '../../utils/until';
import { skipBlocks } from '../../utils/eth';

import {
  generateOffering,
  // generateSomeOfferings
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
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const {
      ws, /* clientWs, */
      allowedScope
    } = settings;

    const until = Until(ws);
    // const clientUntil = Until(clientWs);

    const agentIt = getItFunc({scope: TestScope.AGENT}, allowedScope);
    // const clientIt = getItFunc({scope: TestScope.CLIENT}, allowedScope);

    describe('offerings', () => {
      let offeringId: string;
      let offeringHash: string;
      let offeringToDeleteId: string;

      describe('create offering', () => {
        agentIt('should create an offering', async () => {
          const productId = (await ws.getProducts())[0].id;

          const accounts = await ws.getAccounts();
          const agentWsId = accounts[0].id;

          const templates = await ws.getTemplates('offer' as TemplateType);
          const templateId = templates[0].id;

          offeringId = await ws.createOffering(
            generateOffering(productId, agentWsId, 'Main Service', templateId)
          ) as string;

          expect(offeringId).to.not.be.undefined;
        });

        agentIt('should publish already created offering', async function () {
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime*4);

          const gasPrice = 20*10e9;
          await ws.changeOfferingStatus(offeringId, 'publish', gasPrice);

          await until
            .object('offering')
            .withId(offeringId)
            .prop('status')
            .becomes(OfferStatus.registered);

          const offering = await ws.getOffering(offeringId);
          offeringHash = offering.hash;

          expect(offering.status).to.equal(OfferStatus.registered)
        });
/*
        agentIt('should create some additional offerings', async function() {
          const productId = (await ws.getProducts())[0].id;
          const gasPrice = 20*10e9;
          const accounts = await ws.getAccounts();
          const agentWsId = accounts[0].id;

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          for (let offering of generateSomeOfferings(productId, agentWsId)) {
            const tmpOfferingId = await ws.createOffering(offering);

            await ws.changeOfferingStatus(
              tmpOfferingId, 'publish', gasPrice
            );

            await until
              .object('offering')
              .withId(tmpOfferingId)
              .prop('status')
              .becomes(OfferStatus.registered);
          }
        });
*/
        agentIt('agent: should contain already created offerings', async () => {
          const productId = (await ws.getProducts())[0].id;
          const offerings = await ws.getAgentOfferings(
            productId,
            [OfferStatus.registered],
            0, 10
          ) as PaginatedResponse<Array<Offering>>;

          const offeringForCheck = (offerings.items.filter(offering => offering.id === offeringId))[0];

          // expect(offerings.totalItems).to.equal(4);
          expect(offeringForCheck).to.have.deep.property('id', offeringId);

          offeringToDeleteId = offeringId;
        });
      });

      describe('popup offering', () => {
          /*
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
       */
/*
        agentIt('should popup an offering', async function() {
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 12);

          const blockNumberCreated = (await ws.getOffering(offeringId) as Offering).blockNumberUpdated;

          const gasPrice = 20*10e9;
          await ws.changeOfferingStatus(
            offeringId,
            'popup',
            gasPrice
          );

          await until
            .object('offering')
            .withId(offeringId)
            .prop('status')
            .becomes(OfferStatus.popped_up);

          const blockNumberUpdated = (await ws.getOffering(offeringId) as Offering).blockNumberUpdated;

          expect(blockNumberUpdated > blockNumberCreated).to.be.true;
        });
*/
/*
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
*/
      });

      describe('delete offering', () => {
        agentIt('should delete an offering', async function(){
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 150);

          const gasPrice = 20*10e9;

          await skipBlocks(10, ws, timeouts.blocktime*15, 15000);

          await ws.changeOfferingStatus(
            offeringToDeleteId, 'deactivate', gasPrice
          );

          await until
            .object('offering')
            .withId(offeringToDeleteId)
            .prop('status')
            .becomes(OfferStatus.removed);

          const offering = await ws.getOffering(offeringToDeleteId);

          expect(offering.status).to.equal(OfferStatus.removed)
        });
      });

      console.log(offeringHash);

    });
  }
};
