<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LAT_AR_RCP_SendsMail</fullName>
        <description>LAT_AR_RCP_SendsMail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_AR_Templates/LAT_AR_ReceiptsRejectedTreasury</template>
    </alerts>
    <fieldUpdates>
        <fullName>LAT_AR_RCP_AmountUpdateWithRU</fullName>
        <field>AmountsControl_AR__c</field>
        <formula>IF(ISNULL(LAT_AR_DocumentsAmountWithRU__c),0,LAT_AR_DocumentsAmountWithRU__c) 
+ 
IF(ISNULL(Downpayments_AR__c),0,Downpayments_AR__c) 
- 
IF(ISNULL(Discount_AR__c),0,Discount_AR__c) 
- 
IF(ISNULL(Debit_AR__c),0,Debit_AR__c )</formula>
        <name>LAT_AR_RCP_AmountUpdateWithRU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_RCP_UpdatesSendMailToFalse</fullName>
        <description>Sets to false the field LAT_AR_SendMail__c</description>
        <field>LAT_AR_SendMail__c</field>
        <literalValue>0</literalValue>
        <name>LAT_AR_RCP_UpdatesSendMailToFalse</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_RCP_Update_Original_RecordType</fullName>
        <field>OriginalRecordTypeId__c</field>
        <formula>RecordTypeId</formula>
        <name>LAT RCP Update Original RecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_Receipt_SetValidationStatusCancelled</fullName>
        <field>LAT_ValidationStatus__c</field>
        <literalValue>Cancelado</literalValue>
        <name>Set Validation Status Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RCP_AmountUpdate_AR</fullName>
        <field>AmountsControl_AR__c</field>
        <formula>IF(ValuesAmount_AR__c= 0, 
IF (ISNULL(DocumentsAmount_AR__c) , 0 , DocumentsAmount_AR__c) - IF (ISNULL(DepositsAmount_AR__c) , 0 , DepositsAmount_AR__c) - IF (ISNULL(WithholdingsAmount_AR__c) , 0 , WithholdingsAmount_AR__c) + 
IF (ISNULL(Downpayments_AR__c) , 0 , Downpayments_AR__c) - IF (ISNULL(Formula_Discount__c) , 0 , Formula_Discount__c) - IF (ISNULL(Debit_AR__c) , 0 , Debit_AR__c), 
IF( DepositsAmount_AR__c = 0, 
IF (ISNULL(DocumentsAmount_AR__c) , 0 , DocumentsAmount_AR__c) - IF (ISNULL(ValuesAmount_AR__c) , 0 , ValuesAmount_AR__c) - IF (ISNULL(WithholdingsAmount_AR__c) , 0 , WithholdingsAmount_AR__c) + IF (ISNULL(Downpayments_AR__c) , 0 , Downpayments_AR__c) - IF (ISNULL(Formula_Discount__c) , 0 , Formula_Discount__c) - IF (ISNULL(Debit_AR__c) , 0 , Debit_AR__c) , 
IF (ISNULL(DocumentsAmount_AR__c) , 0 , DocumentsAmount_AR__c) - IF (ISNULL(DepositsAmount_AR__c) , 0 , DepositsAmount_AR__c) - IF (ISNULL(WithholdingsAmount_AR__c) , 0 , WithholdingsAmount_AR__c) + IF (ISNULL(Downpayments_AR__c) , 0 , Downpayments_AR__c) - IF (ISNULL(Formula_Discount__c) , 0 , Formula_Discount__c) 
- IF (ISNULL(Debit_AR__c) , 0 , Debit_AR__c) + IF (ISNULL(ValuesAmount_AR__c) , 0 , ValuesAmount_AR__c) - IF (ISNULL(DepositsAmount_AR__c) , 0 , DepositsAmount_AR__c) ) )</formula>
        <name>RCP_AmountUpdate_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_AR_RCP_WF01_SendEmail</fullName>
        <actions>
            <name>LAT_AR_RCP_SendsMail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>LAT_AR_RCP_UpdatesSendMailToFalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>LAT_AR_SendMail__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_AR_RCP_WF02_AmountFormulaWithRU</fullName>
        <actions>
            <name>LAT_AR_RCP_AmountUpdateWithRU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RCP_Receipt_ARG__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>AR Receipt of Applying Documents</value>
        </criteriaItems>
        <description>Amount Formula With &quot;RU&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LAT_AR_RCP_WF03_CopyOriginalRecordType</fullName>
        <actions>
            <name>LAT_RCP_Update_Original_RecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>RCP_Receipt_ARG__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>RCP_Receipt_ARG__c.OriginalRecordTypeId__c</field>
            <operation>notContain</operation>
            <value>012</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LAT_SetValidationStatusCancelled</fullName>
        <actions>
            <name>LAT_Receipt_SetValidationStatusCancelled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RCP_Receipt_ARG__c.Status_AR__c</field>
            <operation>equals</operation>
            <value>Receipt cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCP_WF01_AmountFormula_AR</fullName>
        <actions>
            <name>RCP_AmountUpdate_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RCP_Receipt_ARG__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>AR Receipt of Applying Documents</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
