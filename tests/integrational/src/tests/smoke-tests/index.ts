import { firstLogin } from './first-login.spec';
import { getEthPrix } from './get-eth-prix.spec';
import { offeringPopup } from './offering-popup.spec';
import { createOffering } from './create-offering.spec';

export const smokeAutoTests = [firstLogin, getEthPrix, offeringPopup, createOffering];
