/*
    Copyright (c) 2016, McCombs School of Business, The University of Texas at Austin
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Kyle Schmid
* @date 2016
* @description Tests for AFFL_AccountVip_TDTM
*/
@isTest
private class AFFL_AccountVip_TEST {

    /*********************************************************************************************************
    * @description Test to see if access isn't changed when vip field is changed for records that shouldn't change
    */
    @isTest
    static void test_access_not_changed() {

        Account a2 = [SELECT Id FROM Account WHERE Name = :'test_acc_2'];

        Contact c1 = [SELECT Id FROM Contact WHERE LastName = :'test1'];
        Contact c2 = [SELECT Id FROM Contact WHERE LastName = :'test2'];

        hed__Affiliation__c affl1 = new hed__Affiliation__c(hed__Contact__c = c1.Id, hed__Account__c = a2.Id, hed__Primary__c = false, hed__Role__c = 'test', hed__Status__c = 'Current');
        hed__Affiliation__c affl2 = new hed__Affiliation__c(hed__Contact__c = c2.Id, hed__Account__c = a2.Id, hed__Primary__c = false, hed__Role__c = 'test', hed__Status__c = 'Current');
        insert new List<hed__Affiliation__c>{affl1, affl2};

        Account adm1 = [SELECT Id, Vip__c FROM Account WHERE Name = :'test1 Administrative Account'];
        Account adm2 = [SELECT Id, Vip__c FROM Account WHERE Name = :'test2 Administrative Account'];

        System.assert(adm1.Vip__c);
        System.assert(adm2.Vip__c);

        Test.startTest();

        adm1.Vip__c = true;
        adm2.Vip__c = false;
        update new List<Account>{adm1, adm2};

        Test.stopTest();

        adm1 = [SELECT Id, Vip__c FROM Account WHERE Name = :'test1 Administrative Account'];
        adm2 = [SELECT Id, Vip__c FROM Account WHERE Name = :'test2 Administrative Account'];
        System.assert(adm1.Vip__c);
        System.assert(adm2.Vip__c);
    }

    /*********************************************************************************************************
    * @description Test setup method
    */
    @testSetup
    static void setup() {

        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();
        tokens.add(new hed.TDTM_Global_API.TdtmToken('AFFL_Security_TDTM', 'Affiliation__c', 'AfterInsert;AfterUpdate;AfterDelete', 5));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('AFFL_SecurityRule_TDTM', 'AffiliationSecurityRule__c', 'AfterInsert;AfterUpdate;AfterDelete', 1));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('AFFL_AccountVip_TDTM', 'Account', 'BeforeUpdate', 5));
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        Account a1 = new Account(Name = 'test_acc_1');
        Account a2 = new Account(Name = 'test_acc_2');
        insert new List<Account>{a1, a2};

        Contact c1 = new Contact(LastName = 'test1');
        Contact c2 = new Contact(LastName = 'test2');
        insert new List<Contact>{c1, c2};
        c2 = [SELECT Id, AccountId FROM Contact WHERE Id = :c2.Id];

        Account adm2 = [SELECT Id, Vip__c FROM Account WHERE Id = :c2.AccountId];
        adm2.Vip__c = true;
        update adm2;

        // We have to use the Vip__c field as the security field, since it is the only
        // checkbox on account that is guranteed to exist as part of affiliation-based security.
        AffiliationSecurityRule__c r1 = new AffiliationSecurityRule__c(SecurityFieldName__c = 'Vip__c', OverrideVip__c = false, Account__c = a1.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        AffiliationSecurityRule__c r2 = new AffiliationSecurityRule__c(SecurityFieldName__c = 'Vip__c', OverrideVip__c = true, Account__c = a2.Id, Primary__c = false, Role__c = 'test', Status__c = 'Current');
        insert new List<AffiliationSecurityRule__c>{r1, r2};
    }
}
