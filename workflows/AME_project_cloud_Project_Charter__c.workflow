<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CCPE_Project_Charter_Approval_Received</fullName>
        <description>CCPE_Project Charter Approval Received</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/CCPE_Proj_Charter_Appr_Receiv</template>
    </alerts>
    <alerts>
        <fullName>CCPE_Project_Charter_Rejection_Received</fullName>
        <description>CCPE_Project Charter Rejection Received</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/CCPE_Proj_Charter_Rejec_Receiv</template>
    </alerts>
    <fieldUpdates>
        <fullName>AME_project_cloud_Project_Charter_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>AME_project_cloud_Project_Charter_w_Infrastructure</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AME_project_cloud_Project_Charter_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Budget</fullName>
        <field>CCPE_Budget_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Data_I</fullName>
        <field>CCPE_Data_Steward_I_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Data I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Data_II</fullName>
        <field>CCPE_Data_Steward_II_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Data II</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Data_III</fullName>
        <field>CCPE_Data_Steward_III_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Data III</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_IT</fullName>
        <field>AME_project_cloud_IT_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval IT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_ITSS_I</fullName>
        <field>CCPE_ITSS_Approval_I_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval ITSS I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_ITSS_II</fullName>
        <field>CCPE_ITSS_Approval_II_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval ITSS II</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Infra</fullName>
        <field>CCPE_Infrastructure_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Infra</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Solutions</fullName>
        <field>CCPE_Solutions_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Solutions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Sponsor_I</fullName>
        <field>CCPE_Sponsor_Approval_I_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Sponsor I</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approval_Sponsor_II</fullName>
        <field>CCPE_Sponsor_Approval_II_Date__c</field>
        <formula>TODAY()</formula>
        <name>CCPE_Project Charter Approval Sponsor II</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CCPE_Project Charter Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Locked</fullName>
        <field>CCPE_Locked__c</field>
        <literalValue>1</literalValue>
        <name>CCPE_Project Charter Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Not_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Not Submitted</literalValue>
        <name>CCPE_Project Charter Not Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>CCPE_Project Charter Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>CCPE_Project Charter Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPE_Project_Charter_Unlocked</fullName>
        <field>CCPE_Locked__c</field>
        <literalValue>0</literalValue>
        <name>CCPE_Project Charter Unlocked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AME_project_cloud_Project_Charter_Update</fullName>
        <actions>
            <name>AME_project_cloud_Project_Charter_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AME_project_cloud_Project_Charter__c.AME_project_cloud_Req_Infra_Involvement__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>This updates the layout of the Project Charter to include additional details when indicated that a project requires infrastructure involvement.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
