import { useBackend } from '../backend';
import { Section, Dropdown, Button, Flex, LabeledList } from '../components';
import { Window } from '../layouts';

export const WeaponManagementPanel = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section>
      <Button
        onClick={() => {act("add_weapon_group")}}
        icon="plus"
        content="New group"
        tooltip="Add Group"/>
      <Button
        icon="rotate-left"
        content="Reset"
        tooltip="Default Sort"
        onClick={() => {act("default_sort_weapons")}}/>
      <br />
      {!!data.weapon_groups && Object.keys(data.weapon_groups).map(key => {
        let group_data = data.weapon_groups[key];
        return (
          <Section
            key={key}
            title={group_data.name}>
              <Button
                onClick={() => {act("select_weapon_group", {group_id: group_data.id})}}
                content="Select"
                color={data.selected_weapon_group === group_data.name ? "green" : "blue"}/>
              <Button
                icon="plus"
                tooltip="Add weapon to group"
                onClick={() => act("add_weapon", {group_id: group_data.id})}/>
              <Button
                icon="pen"
                tooltip="Rename"
                onClick={() => act("rename_weapon_group", {group_id: group_data.id})}/>
              <Button
                icon="minus"
                tooltip="Delete"
                onClick={() => act("delete_weapon_group", {group_id: group_data.id})}/>
              {!!data.debug_rights && (
                <>
                  <Button
                    icon="eye"
                    tooltip="View Variables"
                    onClick={() => act("view_vars", {target: group_data.id})}/>
                </>
              )}
              <br />
              <LabeledList>
                {!!group_data.weapons && Object.keys(group_data.weapons).map(key2 => {
                  let weapon_data = group_data.weapons[key2];
                  return(
                    <LabeledList.Item label={weapon_data.name}>
                      <Button
                        icon="minus"
                        tooltip="Remove from group"
                        onClick={() => act("remove_weapon", {group_id: group_data.id, weapon_id: weapon_data.id})}/>
                      {!!data.debug_rights && (
                        <>
                          <Button
                            icon="eye"
                            tooltip="View Variables"
                            onClick={() => act("view_vars", {target: weapon_data.id})}/>
                        </>
                      )}
                    </LabeledList.Item>
                  )
                })}
              </LabeledList>
          </Section>
          );
      })}
    </Section>
  )
}
