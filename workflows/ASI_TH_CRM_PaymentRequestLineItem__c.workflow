<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_PaymentRequestI</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_TH_CRM_Payment_Request__r.ASI_CRM_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_PaymentRequestI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_PRLineItemAmt</fullName>
        <field>ASI_TH_CRM_Amount__c</field>
        <formula>IF((TEXT(ASI_TH_CRM_COA__c) = &apos;Fund - FOC&apos; || TEXT(ASI_TH_CRM_COA__c) = &apos;Activity - FOC&apos;),
(ASI_TH_CRM_Subbrand__r.ASI_TH_CRM_Price__c *  ASI_TH_CRM_Quantity__c),
(ASI_TH_CRM_UnitCost__c *  ASI_TH_CRM_Quantity__c))</formula>
        <name>ASI_TH_CRM_PRLineItemAmt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_Unit_Cost</fullName>
        <field>ASI_TH_CRM_UnitCost__c</field>
        <formula>IF(NOT(ISNULL(ASI_TH_CRM_Subbrand__r.ASI_TH_CRM_Price__c)),
ASI_TH_CRM_Subbrand__r.ASI_TH_CRM_Price__c,
0)</formula>
        <name>ASI_TH_CRM_Unit_Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_Update_FOC_VAT</fullName>
        <description>For TH CRM P2 Enhancement, updates VAT = 0% if user updates COA to FOC</description>
        <field>ASI_TH_CRM_VAT__c</field>
        <literalValue>0%</literalValue>
        <name>ASI_TH_CRM_Update_FOC_VAT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ASI_TH_CRM_Payment_Request__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_PaymentRequestItem</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_PaymentRequestI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM MY Payment Request Detail</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TH_CRM_PRLineitemAmt</fullName>
        <actions>
            <name>ASI_TH_CRM_PRLineItemAmt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI TH CRM Payment Request Detail</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.ASI_TH_CRM_Quantity__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequest__c.ASI_TH_CRM_Status__c</field>
            <operation>equals</operation>
            <value>Draft,Ready for Approval</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TH_CRM_Unit_Cost</fullName>
        <actions>
            <name>ASI_TH_CRM_Unit_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI TH CRM Payment Request Detail</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.ASI_TH_CRM_COA__c</field>
            <operation>equals</operation>
            <value>Fund - FOC,Activity - FOC</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequest__c.ASI_TH_CRM_Status__c</field>
            <operation>equals</operation>
            <value>Draft,Ready for Approval</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TH_CRM_Update_FOC_VAT</fullName>
        <actions>
            <name>ASI_TH_CRM_Update_FOC_VAT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.ASI_TH_CRM_COA__c</field>
            <operation>equals</operation>
            <value>Fund - FOC,Activity - FOC</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TH_CRM_PaymentRequestLineItem__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI TH CRM Payment Request Detail</value>
        </criteriaItems>
        <description>TH CRM2 Enhancement, updates VAT to 0% if FOC line is present</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
