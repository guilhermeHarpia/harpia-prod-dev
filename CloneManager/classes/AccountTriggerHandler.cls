public without sharing class AccountTriggerHandler {
    private static final AccountTriggerHandler instance = new AccountTriggerHandler();

    private AccountTriggerHandler() {
    }

    public static AccountTriggerHandler getInstance() {
        return instance;
    }

    public void beforeUpdate() {
        Profile profileName = ProfileMap.getInstance()
            .getProfileById(UserInfo.getProfileId());

        System.debug('Profile name ::: ' + profileName.Name);

        //Armazena a lista de novas contas inseridas
        List<Account> insertedAcc = (List<Account>) Trigger.New;
        List<Account> accBeforeChange = (List<Account>) Trigger.Old;
        Map<Id, Account> accOldMap = (Map<Id, Account>) Trigger.OldMap;

        //Captura a primeira conta da lista --> Nesse cenário terá apenas 1 conta na lista
        Account acc = insertedAcc.get(0);
        Account oldAcc = accBeforeChange.get(0);

        System.debug('InsertedAcc :::: ' + acc);
        
        List<Id> accIdList = new List<Id>();
        for(Account accNew : insertedAcc){
            if(String.isBlank(accNew.InstructionsKey__c))
                accIdList.add(accNew.Id);
        }
        
        /*if(!accIdList.isEmpty())
            verifyCreditArea(accIdList);*/

        //Popula os dados da Conta Matriz
        // delegado para AccountDefaultFieldsHandler
        AccountTriggerHelper.populateHeadOfficeInfo(acc);

        //Identifica que tipo de registro está na conta
        Id MERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Mercado Externo')
            .getRecordTypeId();

        //Identifica o tipo de registro da Entidade
        Id EntityTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Entidades')
            .getRecordTypeId();
        Id PartnerGroupId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Parceiro Agrupador')
            .getRecordTypeId();

       
     
      
        //PMC-441
        System.debug('SuframaRules');
        suframaRules(insertedAcc, accOldMap);

        //Cria exceção para que o perfil de System Administrator não deve passar nesta validação

        if (
            userinfo.getName() != 'Integracao ECC' &&
            acc.RecordTypeId != EntityTypeId &&
            acc.RecordTypeId != PartnerGroupId
        ) {
            // AtualizaEnderecoUpper(acc);
            AccountTriggerHelper.populateSalesOffice(acc);
        }

        //Atualiza Ficha de Crédito
        //if(profileName.Name != 'Cadastro'){
        if (
            acc.RecordTypeId != MERecordTypeId &&
            acc.RecordTypeId != EntityTypeId &&
            acc.RecordTypeId != PartnerGroupId
        ) {
            if (
                acc.AccountType__c == 'C' && String.isBlank(acc.SapCode__c) &&
                acc.SalesOffice__c != oldacc.SalesOffice__c
            )
                AccountTriggerHelper.createCreditArea(acc);
            //updateCreditArea();
        }
        //}

        if (
            profileName.Name == 'COMERCIAL PARTNER' ||
            profileName.Name == 'COMERCIAL DISTRIBUIÇÃO PARTNER'
        ) {
            List<CustomAccountTeam__c> customAccTM = [
                SELECT Id, TeamMember__c, Account__c, OwnerId
                FROM CustomAccountTeam__c
                WHERE OwnerId =: acc.OwnerId
            ];

            List<CustomAccountTeam__c> customAccTM2 = [
                SELECT Id, TeamMember__c, Account__c, OwnerId
                FROM CustomAccountTeam__c
            ];

            System.debug('customAccTM2: ' + customAccTM2[0].OwnerId);
            System.debug('acc.OwnerId: ' + acc.OwnerId);

            Boolean canEdit = false;
            if (acc.OwnerId == UserInfo.getUserId()) {
                canEdit = true;
            }
            else if (customAccTM.size() > 0) {
                for (CustomAccountTeam__c teamMember : customAccTM) {
                    if (teamMember.OwnerId == UserInfo.getUserId() || teamMember.TeamMember__c == UserInfo.getUserId()) {
                        if(teamMember.Account__c == null || teamMember.Account__c == acc.Id) {
                            canEdit = true;
                            break;
                        }
                    }
                }
            }

            if(!canEdit) {
                AccountTriggerValidations.validateChangedFields(acc, oldAcc);
            }
        }

        if (
            userinfo.getName() == 'Integracao ECC' &&
            (acc.StateRegistration__c == '' ||
             acc.StateRegistration__c == null)
        ) {
            acc.StateRegistration__c = 'ISENTO';
        }
    }

    public void beforeInsert() {
        //Armazena a lista de novas contas inseridas
        List<Account> insertedAcc = (List<Account>) Trigger.New;

        //Captura a primeira conta da lista --> Nesse cenário terá apenas 1 conta na lista
        Account acc = insertedAcc.get(0);

        verifyCNPJCPFDuplicity();
        AccountTriggerValidations.verifyAccountSalesArea(acc);

        //Identifica que tipo de registro está na conta
        Id MERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Mercado Externo')
            .getRecordTypeId();

        //Identifica o tipo de registro da Entidade
        Id EntityTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Entidades')
            .getRecordTypeId();

        //Identifica o tipo de registro do Parceiro Agrupador
        Id PartnerGroupId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Parceiro Agrupador')
            .getRecordTypeId();

        Id PJRecId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Jurídica - CNPJ')
            .getRecordTypeId();
        Id PFRecId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Física - CPF')
            .getRecordTypeId();

        

        

        boolean isClone = verifyIsClone();
        // Delegado para o 'after insert', na classe 'AccountCloningRules', que
        // vai copiar os registros relacionados da conta original caso a conta
        // a ser inserida seja um clone.

        if (isClone) {
            // AccountTriggerHelper.AtualizaEnderecoUpper(acc);
            ValidationClonedAccount.ClonedAccount(acc);
            acc.ClonedAccount__c = true;
            //Captura conta original que foi clonada para que o Owner seja igual de quem está clonando
            List<Account> clonedAccount = [SELECT Id, Name ,OwnerId FROM Account WHERE Id = :acc.getCloneSourceId() ];
            acc.OwnerId = ClonedAccount.get(0).OwnerId;
           
        }

        //Cria exceção para que o perfil de System Administrator não deve passar nesta validação
        system.debug('MERecordTypeId ' + MERecordTypeId);
        system.debug('RecordTypeId ' + acc.RecordTypeId);
        if (userinfo.getName() != 'Integracao ECC') {
            AccountTriggerHelper.populateSalesOffice(acc);
        }
        if (
            acc.RecordTypeId == MERecordTypeId ||
            acc.RecordTypeId == EntityTypeId ||
            acc.RecordTypeId == PartnerGroupId
        ) {
            acc.LoadingFlag__c = false;
        }

        //PMC-64 - Preenche Método de Pagamento Default "A" e "Z"
        //Comentando depois da realização da estória 140563 (AMS)
        //AccountTriggerHelper.populatePaymentMethods(acc);

        
        if (
            userinfo.getName() == 'Integracao ECC' &&
            (acc.StateRegistration__c == '' ||
            acc.StateRegistration__c == null)
        ) {
            acc.StateRegistration__c = 'ISENTO';
        }

        //PMC-441
        suframaRules(insertedAcc, null);
    }

    public void beforeDelete() {
    }

    public void afterUpdate() {
        List<Account> insertedAcc = (List<Account>) Trigger.New;
        List<Account> accBeforeChange = (List<Account>) Trigger.Old;

        Account acc = insertedAcc.get(0);
        Account oldAcc = accBeforeChange.get(0);

        /* SE FOR DESCOMENTADO UM DIA, JÁ ESTÁ COM A CHAMADA ATUALIZADA PARA A INTEGRAÇÃO
        if(acc.ECCIntegrated__c == false){
            System.enqueueJob(new AccountToECCTransaction(updatedCase.AccountId));
        }
        */

        //Identifica os Ids dos tipos de registro de PF e de PJ
        Id pjRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Jurídica (CNPJ)')
            .getRecordTypeId();
        Id pfRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Física (CPF)')
            .getRecordTypeId();

        //Identifica o tipo de registro do Parceiro Agrupador
        Id PartnerGroupId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Parceiro Agrupador')
            .getRecordTypeId();

        

        Map<Id, Id> MapAccNewSO = new Map<Id, Id>();
        Map<Id, Id> MapAccOldSO = new Map<Id, Id>();
        for (Account UpAcc : insertedAcc) {
            Account oldUpAcc = (Account) Trigger.oldMap.get(UpAcc.Id);
            if (UpAcc.SalesOffice__c != oldUpAcc.SalesOffice__c) {
                MapAccNewSO.put(UpAcc.Id, UpAcc.SalesOffice__c);
                MapAccOldSO.put(oldUpAcc.Id, oldUpAcc.SalesOffice__c);
            }
        }
        if(!MapAccNewSO.isEmpty()) AddManagerToAccTeam(MapAccNewSO, MapAccOldSO);
    }

    public void afterInsert() {
        List<Account> insertedAcc = (List<Account>) Trigger.New;
        Account acc = insertedAcc.get(0);

        //Identifica que tipo de registro está na conta
        Id MERecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Mercado Externo')
            .getRecordTypeId();
        Id EntityTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Entidades')
            .getRecordTypeId();
        Id slaAdminRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('SLAAdmin')
            .getRecordTypeId();
        //Identifica o tipo de registro do Parceiro Agrupador
        Id PartnerGroupId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Parceiro Agrupador')
            .getRecordTypeId();
        //Id EntregaPJRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('PJ - Endereço de Entrega ou Cobrança').getRecordTypeId();
        //Id EntregaPFRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('PF - Endereço de Entrega ou Cobrança').getRecordTypeId();

        boolean isClone = verifyIsClone();
        if (acc.RecordTypeId != slaAdminRecordTypeId) {
            createEntitlement.create(acc);
        }
        if (acc.RecordTypeId == slaAdminRecordTypeId) {
            createEntitlement.createSLA(acc);
        }
        //TRECHO COMENTADO POIS ESTAVA DUPLICANDO ÁREA DE VENDAS COM MÉTODO DA CLASSE ACCOUNTCLONING RULES
        /*if (
             isClone &&
             acc.RecordTypeId != EntityTypeId &&
             acc.RecordTypeId != PartnerGroupId
        ) {
             cloneRelatedLists();
        }*/
        if (
            (acc.SintegraFlag__c == true) &&
            (Test.isRunningTest() == false) &&
            (MERecordTypeId != acc.RecordTypeId) &&
            (EntityTypeId != acc.RecordTypeId) &&
            (acc.RecordTypeId != PartnerGroupId)
        ) {
            System.debug('Entrando Sintegra');

            //chama a integração de pesquisa de cliente no ECC
            //String vPesquisaECC =  searchECC(acc.Id);
            searchECC(acc.Id);

            // Boolean aux = LoadingPageController.getAccountData(acc.Id);
            //if(vPesquisaECC == 'Cliente não existe'){
            //	atualizaSintegra(acc.Id);
            //}
        }

        Map<Id, Id> MapAccNewSO = new Map<Id, Id>();
        for (Account UpAcc : insertedAcc) {
            MapAccNewSO.put(UpAcc.Id, UpAcc.SalesOffice__c);
        }
        AddManagerToAccTeam(MapAccNewSO, null);

    }

    public void afterDelete() {
    }

    public boolean verifyIsClone() {
        

        return (
            Trigger.isExecuting &&
            Trigger.new != null && (
                Trigger.new[0].get('ClonedAccount__c') == true ||
                Trigger.new[0].isClone()
            )
        );
    }

    public void verifyCNPJCPFDuplicity() {

        // Delegado para a classe 'AccountCloningRules' na refatoração.

        // Account duplicateAcc;

        //Identifica os Ids dos tipos de registro e de PF e de PJ
        Id pjRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Jurídica (CNPJ)')
            .getRecordTypeId();

        Id pfRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Física (CPF)')
            .getRecordTypeId();

        Id pjRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Jurídica - CNPJ')
            .getRecordTypeId();

        Id pfRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Pessoa Física - CPF')
            .getRecordTypeId();

        //Armazena a lista de novas contas inseridas
        List<Account> insertedAcc = (List<Account>) Trigger.New;

        //Captura a primeira conta da lista --> Nesse cenário terá apenas 1 conta na lista
        Account acc = insertedAcc.get(0);

        List<Account> duplicatePjListAcc = [
            SELECT Id, Cnpj__c, SapCode__c, CreatedDate
            FROM Account
            WHERE
                Cnpj__c != null
                AND Cnpj__c = :acc.Cnpj__c
                AND AccountType__c = 'C'
            ORDER BY SapCreatedDate__c NULLS LAST
            LIMIT 1
        ];
        List<Account> duplicatePfListAcc = [
            SELECT Id, CPF__c, SapCode__c, CreatedDate
            FROM Account
            WHERE
                CPF__c != null
                AND CPF__c = :acc.CPF__c
                AND AccountType__c = 'C'
            ORDER BY SapCreatedDate__c NULLS LAST
            LIMIT 1
        ];

        AccountTriggerValidations atv = new AccountTriggerValidations();
        //Verifica se a criação da conta é um clone, caso não seja, faz as verificações para possivelmente chamar API

        if (!acc.isClone() && acc.ClonedAccount__c != true) {
            atv.validateDuplicateNotClone(
                acc,
                duplicatePjListAcc,
                duplicatePfListAcc
            );
        } else {
            //REGRAS DE CLONE
            List<String> clonedFieldNames = FieldsetUtils.getFieldNames(
                'Account',
                'ClonedDefaultFields'
            );
            //Conta será clonada se o estado for diferente da conta de origem
            //     //List<Account> clonedAccountList = [SELECT Id, BillingState, AccountType__c, BillingPostalCode, AddressNumber__c, //Type, FiscalSituation__c, StateRegistrationSituation__c, FiscalResidence__c, TaxRegime__c, Suframa__c, AvailableFrom__c, AvailableUntil__c, SubFiscalGroup__c, ICMSTaxPayer__c, DateSintegraIntegration__c, ABCClass__c, CompanyBank__c, Incoterms__c, CurrencyType__c, CreditArea__c, PaymentMethods__c, ICMS__c, IPI__c, CreatedDate, InstructionsKey__c, CFOPCategory__c, ClientSchema__c, CodeSector1__c, CodeSector2__c, ConciliationAccount__c, AccountingClassifGrp__c, HeadOfficeBusinessUnit__c, PricingGroup__c, Incoterms2__c, Segment__c, SubSegment__c, IndustrialSector__c, ShippingCondition__c, SortKey__c, InterestCode__c, TAdminGroup__c, TaxClassification__c, PaymentPeriod__c, ResponsableGroup__c, RiskClass__c, SIMEI__c, SINAC__c, LoyaltyProgram__c, AccountSource, Industry, Ownership, Rating, OtherParticularities__c, DischargeType__c, DischargeObs__c, nsportZone__c, HeadOfficeSapCode__c
            //     //from Account WHERE Id =: acc.getCloneSourceId() /*OR (Cnpj__c =: acc.Cnpj__c AND Cnpj__c != null AND AccountType__c =  AND AccountType__c != null)*/];
            List<Account> clonedAccountList = Database.query(
                'SELECT Id, BillingState, AccountType__c, BillingPostalCode, AddressNumber__c, ' +
                String.join(clonedFieldNames, ',') +
                ' from Account WHERE Id =\'' +
                acc.getCloneSourceId() +
                '\''
            );
            Account clonedAccount = clonedAccountList.get(0);
            
            //Seta alguns campos da nova conta que não podem ser iguais ao da conta clonada
            acc.SapCode__c = null;
            acc.AccountStatus__c = 'Pendente';
            acc.FoundationDate__c = null;
            
            for (String fieldName : clonedFieldNames) {
                if (
                    clonedAccount.get(fieldName) != '' &&
                    clonedAccount.get(fieldName) != null
                ) {
                    acc.put(fieldName, clonedAccount.get(fieldName));
                }
            }
        } //FIM REGRAS DE CLONE
    }

    /* public void cloneRelatedLists() {
        // Armazena a lista de novas contas inseridas
           List<Account> insertedAcc = (List<Account>) Trigger.New;
           //Captura a primeira conta da lista --> Nesse cenário terá apenas 1 conta na lista
           Account acc = insertedAcc.get(0);
           system.debug('orgname ==> ' + userinfo.getOrganizationName());
           system.debug('user type' + userinfo.getUserType());
           system.debug('' + userinfo.getUserId());
           List<PartnerAccount__c> partnerToInsertList = new List<PartnerAccount__c>();
           List<SalesArea__c> salesAreaToInsertList = new List<SalesArea__c>();
           List<CustomerCNAE__c> customerCNAEToInsertList = new List<CustomerCNAE__c>();
           //Captura conta original que foi clonada
           List<Account> clonedAccount = [
               SELECT Id, Name
               FROM Account
               WHERE
                   Id = :acc.getCloneSourceId()
                   OR (Cnpj__c = :acc.Cnpj__c
                   AND Cnpj__c != null
                   AND AccountType__c = 'C'
                   AND AccountType__c != null)
           ];
           Id clonedAccountId = clonedAccount.get(0).Id;
           //CAPTURA RELAÇÃO DE PARCEIROS
           //List<PartnerAccount__c> partnerAcc = [SELECT Id, PartnerType__c, PartnerAccount__c
           //FROM PartnerAccount__c
           //WHERE MainAccount__c = :clonedAccountId];
           //CAPTURAR ÁREA DE VENDAS
           List<SalesArea__c> salesAreaAcc = [
               SELECT
                   Id,
                   Company__c,
                   SalesOrganization__c,
                   ActivitySector__c,
                   DistribuitionChannel__c,
                   PrincingGroup__c,
                   ClientSchema__c
               FROM SalesArea__c
               WHERE ParentAccount__c = :clonedAccountId
           ];
           //CAPTURAR CNAE
           List<CustomerCNAE__c> customerCnaeAcc = [
               SELECT Id, Name, CNAENumber__c, CNAEType__c
               FROM CustomerCNAE__c
               WHERE Customer__c = :clonedAccountId
           ];
           //INSERIR PARCEIROS
           /*if(acc.AccountType__c == 'C' ){
    or(PartnerAccount__c pAcc : partnerAcc){
    artnerAccount__c partnerToInsert = new PartnerAccount__c();
    artnerToInsert.MainAccount__c = acc.Id;
    artnerToInsert.PartnerAccount__c = pAcc.PartnerAccount__c;
    artnerToInsert.PartnerType__c = pAcc.PartnerType__c;
    artnerToInsertList.add(partnerToInsert);
    
           //INSERIR ÁREA DE VENDAS
           for (SalesArea__c sAcc : salesAreaAcc) {
               SalesArea__c salesAreaToInsert = new SalesArea__c();
               salesAreaToInsert.ParentAccount__c = acc.Id;
               salesAreaToInsert.Company__c = sAcc.Company__c;
               salesAreaToInsert.SalesOrganization__c = sAcc.SalesOrganization__c;
               salesAreaToInsert.ActivitySector__c = sAcc.ActivitySector__c;
               salesAreaToInsert.DistribuitionChannel__c = sAcc.DistribuitionChannel__c;
               salesAreaToInsert.ClientSchema__c = sAcc.ClientSchema__c;
               salesAreaToInsert.PrincingGroup__c = sAcc.PrincingGroup__c;
               salesAreaToInsertList.add(salesAreaToInsert);
           }
           //INSERIR RELAÇÃO DE CNAE
           for (CustomerCNAE__c cnaeAcc : customerCnaeAcc) {
               CustomerCNAE__c customerCNAEToInsert = new CustomerCNAE__c();
               customerCNAEToInsert.Customer__c = acc.Id;
               customerCNAEToInsert.Name = cnaeAcc.Name;
               customerCNAEToInsert.CNAENumber__c = cnaeAcc.CNAENumber__c;
               customerCNAEToInsert.CNAEType__c = cnaeAcc.CNAEType__c;
               customerCNAEToInsertList.add(customerCNAEToInsert);
           }
           if (!customerCNAEToInsertList.isEmpty()) {
               insert customerCNAEToInsertList;
               system.debug('inseriu cnae' + customerCNAEToInsertList);
           }
           if (!salesAreaToInsertList.isEmpty()) {
               insert salesAreaToInsertList;
           }
        //Clona Equipe de Conta
        // List<AccountTeamMember> CustomAccountTeamToInsertList = new List<AccountTeamMember>();
    //         // for (AccountTeamMember CATAcc : [SELECT Id, AccountId, TeamMemberRole, UserId, AccountAccessLevel, nityAccessLevel, CaseAccessLevel FROM AccountTeamMember WHERE AccountId = :clonedAccountId]) {
        //     AccountTeamMember NewCAT = new AccountTeamMember();
        //     NewCAT.AccountId = acc.Id;
        //     NewCAT.TeamMemberRole = CATAcc.TeamMemberRole;
        //     NewCAT.UserId = CATAcc.UserId;
        //     NewCAT.AccountAccessLevel = CATAcc.AccountAccessLevel;
        //     NewCAT.OpportunityAccessLevel = CATAcc.OpportunityAccessLevel;
        //     NewCAT.CaseAccessLevel = CATAcc.CaseAccessLevel;
        //     system.debug(NewCAT);
        //     CustomAccountTeamToInsertList.add(NewCAT);
        // }
        // system.debug(CustomAccountTeamToInsertList);
        // if(!CustomAccountTeamToInsertList.isEmpty()) insert CustomAccountTeamToInsertList;
        // if(!partnerToInsertList.isEmpty()){
        //     insert partnerToInsertList;
        // }
    }

    /*public void atualizaSintegra(Id vId){
List<String> Sintegra = new list<String>{vId};
String vRetorno = SintegraIntegration.authorization(Sintegra);
}*/

    public void searchECC(Id vId) {
        //String vretorno;
        //vRetorno =
        SearchCustomerECC.SearchCustomerECC(vId);
        //return (vRetorno);
        //System.enqueuejob(new SearchCustomerECC(vId));
    }
    //PMC-441
    public void suframaRules(
        List<Account> accList,
        Map<Id, Account> accOldMap
    ) {
        List<Account> accToUpdate = new List<Account>();
        Map<Account, String> stateMap = new Map<Account, String>();

        //Insert
        if (accOldMap == null) {
            for (Account acc : accList) {
                //Se os campos de Cidade e endereço forem preenchidos
                if (
                    (!String.isEmpty(acc.BillingCity) &&
                    !String.isEmpty(acc.BillingState))|| !String.isEmpty(acc.Suframa__c)
                ) {
                    stateMap.put(acc, acc.BillingState);
                }
            }
            if (!stateMap.IsEmpty())
                suframaAccToUpdate(stateMap);
        } else {
            //Update
            for (Account acc : accList) {
                //Se os campos de Cidade e endereço forem alterados e os campos estiverem preenchidos
                if (
                    (acc.BillingCity != accOldMap.get(acc.Id).BillingCity ||
                     acc.BillingState != accOldMap.get(acc.Id).BillingState ||
                     acc.Suframa__c != accOldMap.get(acc.Id).Suframa__c ||
                     acc.AccountingClassifGrp__c != accOldMap.get(acc.Id).AccountingClassifGrp__c) && 
                     !String.isEmpty(acc.AccountingClassifGrp__c) && !String.isEmpty(acc.BillingCity) 
                     && !String.isEmpty(acc.BillingState) && !String.isEmpty(acc.Suframa__c)
                ) {
                    stateMap.put(acc, acc.BillingState);
                }
            }
            System.debug('stateMap2: ' + stateMap);
            if (!stateMap.IsEmpty()){
                suframaAccToUpdate(stateMap);
            }
        }
    }

    public void suframaAccToUpdate(Map<Account, String> stateMap) {
        List<SuframaRules__mdt> suframaValues = SuframaMetadataMap.getInstance()
            .getAllSuframaMetadata();
        for (Account acc : stateMap.keySet()) {
            //Verifica se o estado da conta está dentro da CustomMetadata do Suframa
            if (
                SuframaMetadataMap.getInstance()
                    .verifyStateInSuframaMetadata(stateMap.get(acc))
            ) {
                Map<String, Object> returnValues = SuframaMetadataMap.getInstance()
                    .returnCityAndStateSuframaMetadataValues(
                        acc.BillingState,
                        acc.BillingCity
                    );
                //Preenchimento default dos campos para as cidades da Amazonia Ocidental
                if (returnValues.isEmpty()) {
                    acc.SuframaFlag__c = false;
                    acc.TaxClassification__c = '1';
                    acc.AccountingClassifGrp__c = '01';
                } else {
                    //Preenchimento dos campos das Exceções para as cidades da Zona Franca
                    acc.SuframaFlag__c = (Boolean) returnValues.get('Flag');
                    acc.CFOPCategory__c = (String) returnValues.get('CFOP');
                    acc.TaxClassification__c = (String) returnValues.get(
                        'ClassificacaoFiscal'
                    );
                    acc.AccountingClassifGrp__c = (String) returnValues.get(
                        'ClassificacaoContabil'
                    );
                }
            }
        }
    }
    //Fim PMC - 441

    public void AddManagerToAccTeam(
        Map<Id, Id> MapAccNewSO,
        Map<Id, Id> MapAccOldSO
    ) {
        Map<Id, Map<Id, Id>> MapIntertableUserSO = new Map<Id, Map<Id, Id>>();
        Map<Id, Id> MapSOMngr = new Map<Id, Id>();
        system.debug('MapAccNewSO.values() ==>' + MapAccNewSO.values());
        for (IntertableUserSO__c SO : [
            SELECT Id, SalesOffice__c, User__c
            FROM IntertableUserSO__c
            WHERE
                SalesOffice__c IN :MapAccNewSO.values()
                AND Role__c = 'Gerente'
            AND User__r.IsActive = TRUE
        ]) {
            MapSOMngr = new Map<Id, Id>();
            MapSOMngr.put(SO.SalesOffice__c, SO.User__c);
            MapIntertableUserSO.put(SO.Id, MapSOMngr);
        }
        system.debug('MapIntertableUserSO ==> ' + MapIntertableUserSO);
        /*for(SalesOffice__C SO : [SELECT Id, Gerente__c FROM SalesOffice__c WHERE Id IN: MapAccNewSO.values()]){
MapSOMngr.put(SO.Id,SO.Gerente__c);
}*/

        if (MapAccOldSO != null) {
            List<AccountTeamMember> OldATM = [
                SELECT Id, UserId, TeamMemberRole
                FROM AccountTeamMember
                WHERE
                    AccountId = :MapAccOldSO.keySet()
                    AND TeamMemberRole = 'Gerente do Escritório'
            ];
            system.debug(OldATM);
            if (!OldATM.isEmpty())
                delete OldATM;
        }

        List<AccountTeamMember> NewATMList = new List<AccountTeamMember>();
        for (Id accId : MapAccNewSO.keySet()) {
            String SOId = MapAccNewSO.get(accId);
            for (Id itertableUSOId : MapIntertableUserSO.keySet()) {
                Map<Id, Id> MapSOMngrNew = MapIntertableUserSO.get(
                    itertableUSOId
                );
                system.debug('MapSOMngrNew ==> ' + MapSOMngrNew);
                system.debug(
                    'MapSOMngrNew.get(SOId) ==> ' + MapSOMngrNew.get(SOId)
                );
                if (MapSOMngrNew.get(SOId) != null) {
                    AccountTeamMember NewATM = new AccountTeamMember();
                    NewATM.AccountId = accId;
                    NewATM.UserId = MapSOMngrNew.get(SOId);
                    NewATM.TeamMemberRole = 'Gerente do Escritório';
                    NewATM.CaseAccessLevel = 'Edit';
                    NewATM.OpportunityAccessLevel = 'Edit';
                    NewATM.AccountAccessLevel = 'Edit';
                    NewATM.StartDate__c = system.today();
                    NewATM.EndDate__c = system.today().addYears(30);
                    NewATMList.add(NewATM);
                }
            }
            /*String SOId = MapAccNewSO.get(accId);
if(MapSOMngr.get(SOId) != null){

AccountTeamMember NewATM = New AccountTeamMember();
NewATM.AccountId = accId;
NewATM.UserId = MapSOMngr.get(SOId);
NewATM.TeamMemberRole = 'Gerente do Escritório';
NewATM.CaseAccessLevel = 'Edit';
NewATM.OpportunityAccessLevel = 'Edit';
NewATM.AccountAccessLevel = 'Edit';
NewATM.StartDate__c = system.today();
NewATM.EndDate__c = system.today().addYears(30);
NewATMList.add(NewATM);
}*/
        }
        system.debug(NewATMList);
        //if(!NewATMList.IsEmpty())
        insert NewATMList;
    }
    
    /*public static void verifyCreditArea(List<Id> accIdList){
        List<CreditArea__c> creditList = [SELECT Id,AccountId__c, ResponsibleGroup__c, CustomerCreditGroup__c, CustomerCreditGroup__r.SapCode__c FROM CreditArea__c
                                          WHERE AccountId__c IN: accIdList AND CreditAreaType__c = 'ACSS'];
        
        if(creditList.size() > 0){
            Map<Id, CreditArea__c> creditAccMap = new Map<Id, CreditArea__c>();
            
            for(CreditArea__c cArea : creditList)
                creditAccMap.put(cArea.AccountId__c, cArea);
            
            for(Id accId : accIdList){
                Account acc = (Account)Trigger.newMap.get(accId);
                CreditArea__c cArea = creditAccMap.get(acc.Id);
                
                if(cArea != null){
                    if(!cArea.ResponsibleGroup__c.equalsIgnoreCase('GBH') && cArea.CustomerCreditGroup__c != null)
                        acc.InstructionsKey__c = 'P6';
                    else if(cArea.ResponsibleGroup__c.equalsIgnoreCase('GBH') && cArea.CustomerCreditGroup__c != null){
                        if(cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('041') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('042')){
                            acc.InstructionsKey__c = '';
                        } else if(cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('051') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('052') ||
                                  cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('053') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('054') ||
                                  cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('055') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('056') ||
                                  cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('52') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('53') ||
                                  cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('61') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('62') ||
                                  cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('63') || cArea.CustomerCreditGroup__r.SapCode__c.equalsIgnoreCase('64') && cArea.CustomerCreditGroup__c != null)
                            acc.InstructionsKey__c = 'P3';
                    }
                }
            }
        }
    }*/
}