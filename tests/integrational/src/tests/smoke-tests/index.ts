import { firstLogin } from './first-login.spec';
import { secondLogin } from './second-login.spec';
import { getEthPrix } from './get-eth-prix.spec';
import { transferPrix } from './transfer-prix.spec';
import { offeringPopup } from './offering-popup.spec';

export const smokeAutoTests = [firstLogin, secondLogin, getEthPrix, transferPrix, offeringPopup];

