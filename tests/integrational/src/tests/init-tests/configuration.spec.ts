import { expect } from "chai";
import 'mocha';

import { TestInputSettings } from '../../typings/test-models';

export const configurationCheckTest = (settings: TestInputSettings) => {
  const { configs } = settings;

  describe('configuration check', () => {
    it('config should be read', () => {
      expect(configs).to.not.be.undefined;
    });

    it('config should contain required endpoints', () => {
      expect(configs).to.have.property('agentWsEndpoint');
      expect(configs).to.have.property('clientWsEndpoint');
      expect(configs).to.have.property('getPrixEndpoint');
    });

    it('should be valid environment', () => {
      expect(process.env).to.have.property('TELEGRAM_BOT_USER');
      expect(process.env).to.have.property('TELEGRAM_BOT_PASSWORD');
    });
  });
};
