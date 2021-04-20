<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_TnE_TW_Cross_Charge_Email_Alert</fullName>
        <description>ASI TnE TW Cross Charge Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_TnE_Email_Notice__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_TnE_Email_Template/ASI_TnE_TW_Cross_Charged_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_JP_TnE_Check_Notified</fullName>
        <field>ASI_TnE_Sys_Notified__c</field>
        <literalValue>1</literalValue>
        <name>ASI TnE JP Check Notified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ASI_TnE_ClaimHeader__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_AP_Remarks</fullName>
        <field>ASI_TnE_AP_Remarks__c</field>
        <formula>LEFT(ASI_TnE_Details_of_Expense__c, 30)</formula>
        <name>Set TW AP Remarks</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Dispute_True</fullName>
        <field>ASI_TnE_Dispute__c</field>
        <literalValue>1</literalValue>
        <name>Set Dispute True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Submitted_Payment_Amount</fullName>
        <field>ASI_TnE_Submitted_Payment_Amount__c</field>
        <formula>PRIORVALUE(ASI_TnE_HK_Payment_Amount__c)</formula>
        <name>Set Submitted Payment Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TnE_Set_Sys_Record_Type</fullName>
        <field>ASI_TnE_Sys_Record_Type__c</field>
        <formula>RecordType.DeveloperName</formula>
        <name>Set Sys Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_TnE_HK_Card_Excluded_Auto_Check_Exclude</fullName>
        <actions>
            <name>ASI_TnE_Set_Dispute_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto check the &quot;Excluded&quot; (Dispute) checkbox if user selected Card Excluded Expense Classification</description>
        <formula>AND(     CONTAINS(RecordType.DeveloperName, &quot;ASI_TnE_HK&quot;),     ASI_TnE_Expense_Category__r.Name = &quot;Card Expenses Exclusion&quot;,     NOT(ASI_TnE_Dispute__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TnE_HK_Submitted_Payment_Amount</fullName>
        <actions>
            <name>ASI_TnE_Set_Submitted_Payment_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( !ISPICKVAL( ASI_TnE_ClaimHeader__r.ASI_TnE_Status__c, &quot;Draft&quot;), RecordType.DeveloperName = &quot;ASI_TnE_HK_Claim_Detail&quot;, ISCHANGED( ASI_TnE_HK_Payment_Amount__c ) , ISBLANK( ASI_TnE_Submitted_Payment_Amount__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TnE_TW_Notify_Cross_Charge</fullName>
        <actions>
            <name>ASI_TnE_TW_Cross_Charge_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TnE_ClaimDetail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI TnE TW Claim Detail</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TnE_ClaimDetail__c.ASI_TnE_Email_Notice__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_TnE_ClaimDetail__c.ASI_TnE_Cross_Charging__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
