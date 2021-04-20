<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Atualiza_Oportunidade_em_backorder</fullName>
        <description>Atualiza campo &quot;Existe item em backorder&quot; com o número 1 para identificar que existe ao menos 1 item em back order.</description>
        <field>LAT_BackorderItemExists__c</field>
        <formula>1</formula>
        <name>Atualiza Oportunidade em backorder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>LAT_Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_action</fullName>
        <field>LAT_CDAction__c</field>
        <literalValue>C</literalValue>
        <name>Atualiza action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_percentual_bonifica_o</fullName>
        <field>LAT_PercentualOfBonus__c</field>
        <formula>FLOOR( (LAT_QTBonus__c * 100) / LAT_Quantity__c  )</formula>
        <name>Atualiza percentual bonificação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_quantidade_bonificaao</fullName>
        <field>LAT_QTBonus__c</field>
        <formula>FLOOR( (LAT_PercentualOfBonus__c * LAT_Quantity__c) / 100  )</formula>
        <name>Atualiza quantidade bonificação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_OLI_OpportunityProductJDEUpdate1</fullName>
        <field>LAT_OpportunityProductOrderLineJDE__c</field>
        <formula>LAT_Opportunity__c+&apos;-&apos;+LAT_Product__r.LAT_Sku__c+&apos;-&apos;+LAT_NROrderLine__c</formula>
        <name>LAT_AR_OLI_OpportunityProductJDEUpdate1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_OLI_UpdatesKAMPromisedDate</fullName>
        <field>LAT_MX_KAMPromisedDate__c</field>
        <formula>LAT_Opportunity__r.LAT_DTDelivery__c</formula>
        <name>LAT_MX_OLI_UpdatesKAMPromisedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_OLI_SetTotalWeight</fullName>
        <field>LAT_TotalWeight__c</field>
        <formula>LAT_Product__r.LAT_UnitWeight__c *  LAT_Quantity__c</formula>
        <name>Set Total Weight</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OLI_DiscountAR1_AR</fullName>
        <field>LAT_AR_Discount__c</field>
        <formula>LAT_Discount__c</formula>
        <name>OLI_DiscountAR1_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OLI_DiscountToZero_AR</fullName>
        <field>LAT_Discount__c</field>
        <name>OLI_DiscountToZero_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_AR_OLI_WF02_UniqueOppProd</fullName>
        <actions>
            <name>LAT_AR_OLI_OpportunityProductJDEUpdate1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>1 - New Order ARG,2 - New Order URU,3 - Header Blocked ARG,4 - Header Blocked URU,5 - Order Blocked ARG,6 - Order Blocked URU</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_BR_OLI_WF03_UniqueOppProd</fullName>
        <actions>
            <name>LAT_AR_OLI_OpportunityProductJDEUpdate1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bloqueia alteração,Bloqueia alteração do cabeçalho,Nova oportunidade</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OLI_WF01_UpdatesKAMPromisedDate</fullName>
        <actions>
            <name>LAT_MX_OLI_UpdatesKAMPromisedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>MX Header Blocked,MX Order Blocked,MX New Order</value>
        </criteriaItems>
        <description>Updates KAM promised date with the date &apos;Data de entrega&apos; of the Opportunity parent record.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_OLI_WF02_UniqueOppProd</fullName>
        <actions>
            <name>LAT_AR_OLI_OpportunityProductJDEUpdate1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>MX Header Blocked,MX Order Blocked,MX New Order</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
