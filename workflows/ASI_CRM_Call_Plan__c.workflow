<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_JP_Call_Plan_Approved_Notification_Email_Alert</fullName>
        <description>CRM JP Call Plan Approved Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_Call_Plan_Approved_Notification_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Call_Plan_Recalled_Notification_Email_Alert</fullName>
        <description>CRM JP Call Plan Recalled Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_Approver_1__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_Call_Plan_Recalled_Notification_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_JP_Call_Plan_Rejected_Notification_Email_Alert</fullName>
        <description>CRM JP Call Plan Rejected Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_JP_Email_Templates/ASI_CRM_JP_Call_Plan_Rejected_Notification_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Set_Call_Plan_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Call_Plan_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Call Plan Read-Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Set_Sys_In_Approval_checked</fullName>
        <field>ASI_CRM_Sys_In_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Set Sys_In Approval checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Set_Sys_In_Approval_unchecked</fullName>
        <field>ASI_CRM_Sys_In_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Set Sys_In Approval unchecked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Uncheck_Is_Real_Time_Print</fullName>
        <field>ASI_CRM_Sys_Is_Real_Time_Print__c</field>
        <literalValue>0</literalValue>
        <name>ASI_CRM_JP_Uncheck_Is_Real_Time_Print</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Update_Approved</fullName>
        <field>ASI_CRM_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Update_Call_Plan_Name</fullName>
        <field>Name</field>
        <formula>Owner:User.FirstName &amp;&apos; &apos;&amp;Owner:User.LastName&amp;&apos; (&apos;&amp; TEXT(YEAR(ASI_CRM_Period_From__c))&amp;&apos;/&apos;&amp;IF(MONTH(ASI_CRM_Period_From__c)&lt;10, &apos;0&apos;&amp;TEXT(MONTH(ASI_CRM_Period_From__c)), TEXT(MONTH(ASI_CRM_Period_From__c)))&amp;&apos;/&apos;&amp;IF(DAY(ASI_CRM_Period_From__c)&lt;10, &apos;0&apos;&amp;TEXT(DAY(ASI_CRM_Period_From__c)), TEXT(DAY(ASI_CRM_Period_From__c))) &amp;&apos; - &apos;&amp; TEXT(YEAR(ASI_CRM_Period_To__c))&amp;&apos;/&apos;&amp;IF(MONTH(ASI_CRM_Period_To__c)&lt;10, &apos;0&apos;&amp;TEXT(MONTH(ASI_CRM_Period_To__c)), TEXT(MONTH(ASI_CRM_Period_To__c)))&amp;&apos;/&apos;&amp;IF(DAY(ASI_CRM_Period_To__c)&lt;10, &apos;0&apos;&amp;TEXT(DAY(ASI_CRM_Period_To__c)), TEXT(DAY(ASI_CRM_Period_To__c)))&amp;&apos;)&apos;</formula>
        <name>Update Call Plan Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Set_Sys_Allow_Submit_Aprv_False</fullName>
        <field>ASI_CRM_Sys_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Set Sys Allow Submit Approval False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_JP_Define_Call_Plan_Name</fullName>
        <actions>
            <name>ASI_CRM_JP_Update_Call_Plan_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName=&apos;ASI_CRM_JP_Call_Plan&apos; &amp;&amp; ( ISNEW() || ISCHANGED(ASI_CRM_Period_From__c) ||  ISCHANGED(ASI_CRM_Period_To__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_JP_Update_Is_Real_Time_Print</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Call_Plan__c.ASI_CRM_Sys_Is_Real_Time_Print__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_CRM_JP_Uncheck_Is_Real_Time_Print</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>ASI_CRM_Call_Plan__c.ASI_CRM_Sys_Trigger_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
