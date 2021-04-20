<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CCPE_RFC_Approval_Received</fullName>
        <description>CCPE_RFC Approval Received</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/CCPE_RFC_Approval_Received</template>
    </alerts>
    <alerts>
        <fullName>CCPE_RFC_Rejection_Received</fullName>
        <description>CCPE_RFC Rejection Received</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/CCPE_RFC_Rejection_Received</template>
    </alerts>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Budget</fullName>
        <field>CCPE_Budget_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Data_I</fullName>
        <field>CCPE_Data_Steward_I_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Data I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Data_II</fullName>
        <field>CCPE_Data_Steward_II_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Data II</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Data_III</fullName>
        <field>CCPE_Data_Steward_III_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Data III</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_IT</fullName>
        <field>CCPE_IT_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval IT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_ITSS_I</fullName>
        <field>CCPE_ITSS_Approval_I_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval ITSS I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_ITSS_II</fullName>
        <field>CCPE_ITSS_Approval_II_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval ITSS II</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Infra</fullName>
        <field>CCPE_Infrastructure_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Infra</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Solutions</fullName>
        <field>CCPE_Solutions_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Solutions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Sponsor_I</fullName>
        <field>CCPE_Sponsor_Approval_I_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Sponsor I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Sponsor_II</fullName>
        <field>CCPE_ITSS_Approval_II_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_RFC Approval Sponsor II</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Status_Approved</fullName>
        <field>CCPE_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CCPE_RFC Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Status_Not_Submitted</fullName>
        <field>CCPE_Approval_Status__c</field>
        <literalValue>Not Submitted</literalValue>
        <name>CCPE_RFC Approval Status Not Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Status_Rejected</fullName>
        <field>CCPE_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>CCPE_RFC Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Approval_Status_Submitted</fullName>
        <field>CCPE_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>CCPE_RFC Approval Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Locked</fullName>
        <field>CCPE_Locked__c</field>
        <literalValue>1</literalValue>
        <name>CCPE_RFC Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_RFC_Unlocked</fullName>
        <field>CCPE_Locked__c</field>
        <literalValue>0</literalValue>
        <name>CCPE_RFC Unlocked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
