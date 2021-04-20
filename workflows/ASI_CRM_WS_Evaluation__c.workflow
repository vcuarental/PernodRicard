<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_WS_Evaluation_Approved_Email_Alert</fullName>
        <ccEmails>PRC.WSEval@pernod-ricard.com</ccEmails>
        <description>ASI_CRM_CN_WS_Evaluation_Approved_Email_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>jane.ji@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_WS_Eva_Apprved_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_WS_Evaluation_Rejected_Email_Alert</fullName>
        <ccEmails>PRC.WSEval@pernod-ricard.com</ccEmails>
        <description>ASI_CRM_CN_WS_Evaluation_Rejected_Email_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_WS_Eva_Rejected_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Remove_Submission_Date</fullName>
        <field>ASI_CRM_Submission_Date__c</field>
        <name>CN Remove Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Draft</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Set Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Final</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Final</literalValue>
        <name>Set Status Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Submitted</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Set Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Submission_Date</fullName>
        <field>ASI_CRM_Submission_Date__c</field>
        <formula>NOW()</formula>
        <name>CN Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
