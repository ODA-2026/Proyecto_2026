@EndUserText.label: 'AE - Parameters for Change Status'
define abstract entity ZAE_PARAM_CHANGE_STATUS
{
  @EndUserText.label: 'Change Status:'
  status : zed_status_code_oda;
  @EndUserText.label: 'Add Observation Text:'
  text   : abap.char(80);
}
