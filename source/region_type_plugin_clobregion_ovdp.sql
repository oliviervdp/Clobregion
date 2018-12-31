prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2018.05.24'
,p_release=>'18.2.0.00.12'
,p_default_workspace_id=>7172120952823742243
,p_default_application_id=>49139
,p_default_owner=>'OLIVIERVANDEPERRE'
);
end;
/
prompt --application/shared_components/plugins/region_type/clobregion_ovdp
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(21944493853075572100)
,p_plugin_type=>'REGION TYPE'
,p_name=>'CLOBREGION_OVDP'
,p_display_name=>'Clob Region'
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'#PLUGIN_FILES#clobRegion_plugin.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure print_clob ( ',
'    p_clob         IN CLOB                  ',
'  , p_escape_value IN BOOLEAN)',
'IS',
'    t                     PLS_INTEGER := 1;',
'    l_chunk_sz            PLS_INTEGER := 4000;',
'    l_chunk               VARCHAR2(4000);',
'    l_clob                CLOB;',
'BEGIN',
'    -- set variables for iterations',
'    l_clob := p_clob;',
'    t := 1;',
'    ',
'    WHILE t <= dbms_lob.getlength( l_clob ) LOOP',
'        -- cut chunk from CLOB',
'        l_chunk := dbms_lob.substr( l_clob, l_chunk_sz, t );',
'',
'        apex_debug_message.log_long_message (',
'            p_message    => l_chunk);',
'',
'        -- check if escape output is set and escape value when needed',
'        IF p_escape_value THEN',
'            apex_plugin_util.print_escaped_value( l_chunk );',
'        ELSE',
'            htp.prn( l_chunk );',
'        END IF;',
'',
'        -- increase index for next interaction',
'        t := t + l_chunk_sz;',
'    END LOOP;',
'',
'    -- new line between rows',
'    htp.prn( CHR(13) || CHR(10) );',
'    ',
'END;',
'',
'procedure get_data( p_id IN NUMBER )',
'IS',
'BEGIN',
'    NULL;',
'END;',
'',
'function render (',
'    p_region              in apex_plugin.t_region,',
'    p_plugin              in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean )',
'    return apex_plugin.t_region_render_result',
'IS',
'    c_region_name         constant VARCHAR2(255) := p_region.name;',
'    c_source              constant VARCHAR2(32767) := RTRIM(p_region.source, '';'');',
'    l_data_type_list      apex_application_global.vc_arr2;',
'    ',
'    l_column_value_list   apex_plugin_util.t_column_value_list2;',
'    ',
'    l_clob                CLOB;',
'    ',
'    l_onload_code         VARCHAR2(32767);',
'    ',
'    l_return apex_plugin.t_region_render_result;',
'BEGIN',
'    apex_plugin_util.debug_region( p_plugin, p_region );',
'    ',
'    -- limit expected datatypes to clob',
'    l_data_type_list(1)   := apex_plugin_util.c_data_type_clob;',
'',
'    -- Get the data ',
'    l_column_value_list := apex_plugin_util.get_data2 (',
'                               p_sql_statement      => c_source,',
'                               p_min_columns        => 1,',
'                               p_max_columns        => 1,',
'                               p_data_type_list     => l_data_type_list,',
'                               p_component_name     => c_region_name);',
'    ',
'    -- loop columns',
'    apex_debug.message(''Amount of columns: %s'', l_column_value_list.count);',
'    IF l_column_value_list(1).value_list.count != 0 THEN',
'        FOR i IN 1 .. l_column_value_list.count',
'        LOOP',
'            -- loop column values',
'            apex_debug.message(''Amount of values: %s'', l_column_value_list(i).value_list.count);',
'            FOR x IN 1 .. l_column_value_list(i).value_list.count',
'            LOOP',
'',
'                -- get CLOB from the column value list',
'                l_clob := l_column_value_list(i).value_list(x).clob_value;  ',
'',
'                htp.prn(''<div class="contentContainer">'');',
'                -- print CLOB',
'                print_clob ( ',
'                    p_clob         => l_clob               ',
'                  , p_escape_value => p_region.escape_output',
'                    );',
'                htp.prn(''</div>''); ',
'',
'            END LOOP;',
'        END LOOP;',
'    ELSE ',
'        htp.prn(''<div class="contentContainer">'');',
'            htp.prn(''<p>'');',
'                htp.prn(p_region.no_data_found_message );  ',
'            htp.prn(''</p>''); ',
'        htp.prn(''</div>''); ',
'    END IF;',
'    ',
'    ----- Set Javascript code -----------',
'    l_onload_code := l_onload_code || ''clobRegionPlugin.init( {''||',
'                                                apex_javascript.add_attribute(''item'',  sys.htf.escape_sc(p_region.static_id))||',
'                                                apex_javascript.add_attribute(''ajaxIdentifier'',  sys.htf.escape_sc(apex_plugin.get_ajax_identifier))||',
'                                                apex_javascript.add_attribute(''pageItemsToSubmit'',   apex_plugin_util.page_item_names_to_jquery(p_region.ajax_items_to_submit))||',
'                                      ''} )'';',
'    ',
'    apex_javascript.add_onload_code(l_onload_code);',
'',
'    RETURN l_return;',
'END;',
'',
'function ajax (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin )',
'    return apex_plugin.t_region_ajax_result',
'AS',
'    c_region_name         constant VARCHAR2(255) := p_region.name;',
'    c_source              constant VARCHAR2(32767) := p_region.source;',
'    l_data_type_list      apex_application_global.vc_arr2;',
'    ',
'    l_column_value_list   apex_plugin_util.t_column_value_list2;',
'    ',
'    l_clob                CLOB;',
'    ',
'    l_return apex_plugin.t_region_ajax_result;',
'BEGIN',
'',
'    -- limit expected datatypes to clob',
'    l_data_type_list(1)   := apex_plugin_util.c_data_type_clob;',
'',
'    -- Get the data ',
'    l_column_value_list := apex_plugin_util.get_data2 (',
'                               p_sql_statement      => c_source,',
'                               p_min_columns        => 1,',
'                               p_max_columns        => 1,',
'                               p_data_type_list     => l_data_type_list,',
'                               p_component_name     => c_region_name);',
'    ',
'    -- loop columns',
'    apex_debug.message(''Amount of columns: %s'', l_column_value_list.count);',
'    IF l_column_value_list(1).value_list.count != 0 THEN',
'        FOR i IN 1 .. l_column_value_list.count',
'        LOOP',
'            -- loop column values',
'            apex_debug.message(''Amount of values: %s'', l_column_value_list(i).value_list.count);',
'            FOR x IN 1 .. l_column_value_list(i).value_list.count',
'            LOOP',
'',
'                -- get CLOB from the column value list',
'                l_clob := l_column_value_list(i).value_list(x).clob_value;  ',
'',
'                -- print CLOB',
'                print_clob ( ',
'                    p_clob         => l_clob               ',
'                  , p_escape_value => p_region.escape_output',
'                    );',
'',
'            END LOOP;',
'        END LOOP;',
'    ELSE ',
'        htp.prn(''<div class="contentContainer">'');',
'            htp.prn(''<p>'');',
'                htp.prn(p_region.no_data_found_message );  ',
'            htp.prn(''</p>''); ',
'        htp.prn(''</div>''); ',
'    END IF;',
'',
'    return l_return;',
'END;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'SOURCE_LOCATION:AJAX_ITEMS_TO_SUBMIT:NO_DATA_FOUND_MESSAGE:ESCAPE_OUTPUT:COLUMNS:COLUMN_HEADING'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>8
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(21953437552818267282)
,p_plugin_id=>wwv_flow_api.id(21944493853075572100)
,p_name=>'SOURCE_LOCATION'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2866756E6374696F6E28706172656E742C20242C20756E646566696E6564297B0D0A202020200D0A092F2F20636865636B206966206E6F7420696E697469616C697A6564207965740D0A2020202069662028706172656E742E636C6F62526567696F6E50';
wwv_flow_api.g_varchar2_table(2) := '6C7567696E203D3D3D20756E646566696E656429207B0D0A0D0A2020202020202020706172656E742E636C6F62526567696F6E506C7567696E203D2066756E6374696F6E202829207B0D0A0D0A09092020202F2A2A0D0A0909092A207053657474696E67';
wwv_flow_api.g_varchar2_table(3) := '203D207B0D0A090909096974656D203A2074686520726567696F6E206974656D0D0A09090909616A61784964656E746966696572203A20616A61784964656E746966696572206F662074686520706C7567696E0D0A09090909706167654974656D73546F';
wwv_flow_api.g_varchar2_table(4) := '5375626D6974203A2070616765206974656D732074686174206861766520746F206265207375626D69747465640D0A09090920207D0D0A0909092A2F0D0A09090966756E6374696F6E20696E69742028207053657474696E67732029207B0D0A09090909';
wwv_flow_api.g_varchar2_table(5) := '76617220726567696F6E53656C6563746F722020202020203D202723272B7053657474696E67732E6974656D0D0A0909090920202C20726567696F6E24202020202020202020202020203D202428726567696F6E53656C6563746F72290D0A0909090920';
wwv_flow_api.g_varchar2_table(6) := '202C20616A61784964656E746966696572202020203D207053657474696E67732E616A61784964656E7469666965720D0A0909090920202C20706167654974656D73546F5375626D6974203D207053657474696E67732E706167654974656D73546F5375';
wwv_flow_api.g_varchar2_table(7) := '626D69740D0A090909090D0A090909092F2F2062696E64206170657872656672657368206576656E742068616E646C6572090909090D0A09090909726567696F6E242E6F6E2820276170657872656672657368272C2066756E6374696F6E202865297B0D';
wwv_flow_api.g_varchar2_table(8) := '0A0909090909617065782E64656275672E6C6F6728275265667265736820436C6F62526567696F6E27290D0A0909090909766172206F7074696F6E73203D207B0D0A0909090909096576656E74202020202020202020202020203A20652C0D0A09090909';
wwv_flow_api.g_varchar2_table(9) := '0909616A61784964656E746966696572202020203A20616A61784964656E7469666965722C0D0A090909090909706167654974656D73546F5375626D6974203A20706167654974656D73546F5375626D69740D0A09090909097D0D0A0909090909726566';
wwv_flow_api.g_varchar2_table(10) := '72657368436C6F625265706F7274416A617828206F7074696F6E7320290D0A090909097D290D0A0909097D0D0A0909090D0A0909090D0A09090966756E6374696F6E2072656672657368436C6F625265706F7274416A61782028206F7074696F6E732029';
wwv_flow_api.g_varchar2_table(11) := '7B0D0A090909097661722074617267657424203D2024286F7074696F6E732E6576656E742E746172676574290D0A090909090D0A090909097661722070416A61784964656E746966696572203D206F7074696F6E732E616A61784964656E746966696572';
wwv_flow_api.g_varchar2_table(12) := '0D0A0909090920202C207044617461203D207B20706167654974656D733A206F7074696F6E732E706167654974656D73546F5375626D6974207D0D0A0909090920202C20704F7074696F6E73203D207B20726566726573684F626A656374203A20746172';
wwv_flow_api.g_varchar2_table(13) := '676574242C206C6F6164696E67496E64696361746F72203A20746172676574242C206C6F6164696E67496E64696361746F72506F736974696F6E203A202763656E7465726564272C206461746154797065203A202768746D6C27207D0D0A090909090D0A';
wwv_flow_api.g_varchar2_table(14) := '090909097661722070726F6D697365203D20617065782E7365727665722E706C7567696E282070416A61784964656E7469666965722C2070446174612C20704F7074696F6E7320290D0A090909090D0A0909090970726F6D6973652E646F6E652866756E';
wwv_flow_api.g_varchar2_table(15) := '6374696F6E287044617461297B0D0A0909090909746172676574242E66696E642820272E636F6E74656E74436F6E7461696E65722720292E68746D6C2820704461746120290D0A090909097D29090909090D0A0909097D0D0A0909090D0A0909092F2F20';
wwv_flow_api.g_varchar2_table(16) := '72657475726E207075626C696320696E746572666163650D0A09090972657475726E207B696E6974203A20696E69747D3B0D0A09097D28293B0D0A202020207D0D0A090D0A7D292877696E646F772C20617065782E6A517565727929';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(21958413509231921319)
,p_plugin_id=>wwv_flow_api.id(21944493853075572100)
,p_file_name=>'clobRegion_plugin.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
