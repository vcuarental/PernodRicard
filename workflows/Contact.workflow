<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MMPJ_Ext_Vign_Contact_questionnaire_Champ</fullName>
        <description>MMPJ_Ext_Vign_Contact_questionnaire_Champ</description>
        <protected>false</protected>
        <recipients>
            <recipient>MMPJ_Ext_Vign_Admins_Fonctionnels_Champ</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_Contact_questionnaire</template>
    </alerts>
    <alerts>
        <fullName>MMPJ_Ext_Vign_Contact_questionnaire_Cognac</fullName>
        <description>MMPJ_Ext_Vign_Contact_questionnaire_Cognac</description>
        <protected>false</protected>
        <recipients>
            <recipient>MMPJ_Ext_Vign_Admins_Fonctionnels_Cognac</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_Contact_questionnaire</template>
    </alerts>
    <alerts>
        <fullName>MMPJ_Ext_Vign_Contact_relance</fullName>
        <description>MMPJ_Ext_Vign_Contact_relance</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Relance_Viti</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_UpdateFaxNo</fullName>
        <field>Fax</field>
        <formula>IF(NOT(ISBLANK(ASI_CRM_TW_Fax_Area_Code__c )),&apos;(&apos;+ASI_CRM_TW_Fax_Area_Code__c +&apos;)&apos;,&apos;&apos;)+
 IF(NOT(ISBLANK(ASI_CRM_TW_Fax_Number__c )),ASI_CRM_TW_Fax_Number__c ,&apos;&apos;)</formula>
        <name>ASI_CRM_TW_UpdateFaxNo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_UpdatePhoneNo</fullName>
        <field>Phone</field>
        <formula>IF(NOT(ISBLANK(ASI_CRM_TW_Phone_Area_Code__c)),&apos;(&apos;+ASI_CRM_TW_Phone_Area_Code__c+&apos;)&apos;,&apos;&apos;)+
 IF(NOT(ISBLANK(ASI_CRM_TW_Phone_Number__c)),ASI_CRM_TW_Phone_Number__c,&apos;&apos;)+ 
 IF(NOT(ISBLANK(ASI_CRM_TW_Phone_Ext__c )),&apos; #&apos;+ASI_CRM_TW_Phone_Ext__c,&apos;&apos;)</formula>
        <name>ASI_CRM_TW_UpdatePhoneNo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Assistente_Upper</fullName>
        <field>AssistantName</field>
        <formula>upper ( AssistantName )</formula>
        <name>alt Assistente Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Cargo_Upper</fullName>
        <field>Title</field>
        <formula>UPPER( Title )</formula>
        <name>alt Cargo Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Cidade_corresp_Upper</fullName>
        <field>MailingCity</field>
        <formula>upper( MailingCity )</formula>
        <name>alt Cidade corresp Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Departamento_Upper</fullName>
        <field>Department</field>
        <formula>Upper ( Department )</formula>
        <name>alt Departamento Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Estado_corresp_Upper</fullName>
        <field>MailingState</field>
        <formula>Upper ( MailingState )</formula>
        <name>alt Estado corresp Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Nome_Upper</fullName>
        <field>FirstName</field>
        <formula>Upper ( FirstName )</formula>
        <name>alt Nome Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Orgao_expedidor_Upper</fullName>
        <field>Orgao_expedidor__c</field>
        <formula>upper ( Orgao_expedidor__c )</formula>
        <name>alt Orgão expedidor Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Outra_cidade_Upper</fullName>
        <field>OtherCity</field>
        <formula>upper ( OtherCity )</formula>
        <name>alt Outra cidade Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Outro_estado_upper</fullName>
        <field>OtherState</field>
        <formula>upper ( OtherState )</formula>
        <name>alt Outro estado upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Outro_pais_Upper</fullName>
        <field>OtherCountry</field>
        <formula>upper ( OtherCountry )</formula>
        <name>alt Outro país Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Outro_rua_Upper</fullName>
        <field>OtherStreet</field>
        <formula>upper( OtherStreet )</formula>
        <name>alt Outro rua Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Pais_Upper</fullName>
        <field>MailingCountry</field>
        <formula>upper( MailingCountry )</formula>
        <name>alt País Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Rua_de_corresp_Upper</fullName>
        <field>MailingStreet</field>
        <formula>Upper( MailingStreet )</formula>
        <name>alt Rua de corresp Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>alt_Sobrenome_Upper</fullName>
        <field>LastName</field>
        <formula>Upper ( LastName )</formula>
        <name>alt Sobrenome Upper</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>gvp__Email_Key</fullName>
        <field>gvp__Email_Key__c</field>
        <formula>Email</formula>
        <name>Email Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_TW_UpdateFaxNo</fullName>
        <actions>
            <name>ASI_CRM_TW_UpdateFaxNo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.ASI_CRM_TW_Fax_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_TW_UpdatePhoneNo</fullName>
        <actions>
            <name>ASI_CRM_TW_UpdatePhoneNo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.ASI_CRM_TW_Phone_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Atualiza campos para maiusculos 01</fullName>
        <actions>
            <name>alt_Cargo_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Cidade_corresp_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Departamento_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Estado_corresp_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Nome_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Outra_cidade_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Outro_estado_upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Outro_pais_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Outro_rua_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Sobrenome_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Atualiza campos para maiusculos 02</fullName>
        <actions>
            <name>alt_Assistente_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Pais_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>alt_Rua_de_corresp_Upper</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MMPJ_Ext_Vign_Contact_questionnaire_Champ</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_Contact_questionnaire_Champ</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Extranet Vigneron Viticulteur</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MMPJ_Ext_Vign_premiere_connexion__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MMPJ_Ext_Vign_Contact_Segmentation__c</field>
            <operation>equals</operation>
            <value>Champagne</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MMPJ_Ext_Vign_Contact_questionnaire_Cognac</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_Contact_questionnaire_Cognac</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Extranet Vigneron Viticulteur</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MMPJ_Ext_Vign_premiere_connexion__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MMPJ_Ext_Vign_Contact_Segmentation__c</field>
            <operation>equals</operation>
            <value>Cognac</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MMPJ_Ext_Vign_relance_viticulteur</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_Contact_relance</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Contact.MMPJ_Ext_Vign_Date_de_relance__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.MMPJ_Ext_Vign_Type_de_relance__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Envoi d&apos;un email au contact et à partners-mmpj@pernod-ricard.com dès  que les champs type de relance et date de relance sont renseignés</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>gvp__Copy Email Key</fullName>
        <actions>
            <name>gvp__Email_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.gvp__Email_Key__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Will copy the Contact.Email key for future upserts</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
