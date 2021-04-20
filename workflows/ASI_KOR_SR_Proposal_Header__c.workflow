<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_KOR_SR_Proposal_Approval_Notification</fullName>
        <description>ASI KOR SR Proposal Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_SR_Proposal_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_KOR_SR_Proposal_Rejection_Notification</fullName>
        <description>ASI KOR SR Proposal Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_SR_Proposal_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_KOR_SR_Proposal_Submission_Notification</fullName>
        <description>ASI KOR SR Proposal Submission Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_KOR_SYS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_SR_Proposal_Submitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_KOR_Copy_SR_Manager_Email</fullName>
        <field>ASI_KOR_SYS_Manager_Email__c</field>
        <formula>Owner:User.Manager.Email</formula>
        <name>ASI KOR Copy SR Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_KOR_SYS_Proposal_Month_ID</fullName>
        <field>ASI_KOR_SYS_Proposal_Month_ID__c</field>
        <formula>ASI_KOR_SYS_Proposal_Code__c</formula>
        <name>ASI_KOR_SYS_Proposal_Month_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI KOR SR Proposal Approved</fullName>
        <actions>
            <name>ASI_KOR_SR_Proposal_Approval_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_SR_Proposal_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Approved by BM</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR SR Proposal Created</fullName>
        <actions>
            <name>ASI_KOR_Copy_SR_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_SR_Proposal_Header__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR SR Proposal Rejected</fullName>
        <actions>
            <name>ASI_KOR_SR_Proposal_Rejection_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_SR_Proposal_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR SR Proposal Submitted</fullName>
        <actions>
            <name>ASI_KOR_SR_Proposal_Submission_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_SR_Proposal_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_KOR_SR_Proposal_Header_Check</fullName>
        <actions>
            <name>ASI_KOR_SYS_Proposal_Month_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_SR_Proposal_Header__c.ASI_KOR_SYS_Proposal_Code__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
