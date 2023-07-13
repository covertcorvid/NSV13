import { useBackend } from '../backend';
import { Section, Dropdown, Button, Flex } from '../components';
import { Window } from '../layouts';

export const WeaponManagementPanel = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section title="Armaments:" buttons={
      <>
        <Button fluid
          onClick={() => {act("add_weapon_group")}}
          icon="plus"
          tooltip="Add Group"/>
        <Button fluid
          icon="rotate-left"
          tooltip="Default Sort"
          onClick={() => {act("default_sort_weapons")}}/>
      </>
    }>
      {!!data.weapon_groups && Object.keys(data.weapon_groups).map(key => {
        let group_data = data.weapon_groups[key];
        return (
          <Section
            key={key}
            title={group_data.name}>
              <Button
                icon="pen"
                tooltip="Rename"
                onClick={() => act("rename_weapon_group", {id: group_data.id})}/>
              <Button
                icon="minus"
                tooltip="Delete"
                onClick={() => act("delete_weapon_group", {id: group_data.id})}/>
              <Button
                icon="eye"
                tooltip="View Variables"
                onClick={() => act("view_vars", {target: group_data.id})}/>
              <br />
              {!!group_data.weapons && Object.keys(group_data.weapons).map(key2 => {
                let weapon_data = group_data.weapons[key2];
                return(
                  <>
                    {weapon_data.name}
                    &ensp;<Button
                      icon="eye"
                      tooltip="View Variables"
                      onClick={() => act("view_vars", {target: weapon_data.id})}/>
                    <br />
                  </>
                )
              })}
          </Section>
          );
      })}
    </Section>
  )
}
