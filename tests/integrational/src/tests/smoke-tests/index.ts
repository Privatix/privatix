import { firstLogin } from './first-login.spec';
import { getEthPrix } from './get-eth-prix.spec';
import { transferPrix } from './transfer-prix.spec';
import { offeringPopup } from './offering-popup.spec';

export const smokeAutoTests = [firstLogin, getEthPrix, transferPrix, offeringPopup];
