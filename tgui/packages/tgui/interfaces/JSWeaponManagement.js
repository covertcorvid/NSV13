import { useBackend } from '../backend';
import { Section, Dropdown, Button, Flex } from '../components';
import { Window } from '../layouts';

export const WeaponManagementPanel = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section title="Armaments:" buttons={
      <>
        <Button fluid
          onClick={() => {act("add_group")}}>
          Add Group
        </Button>
        <Button fluid
          onClick={() => {act("default_sort_weapons")}}>
          Reset All
        </Button>
      </>
    }>
      {!!data.weapon_groups && Object.keys(data.weapon_groups).map(key => {
        let group_data = data.weapon_groups[key];
        return (
          <Section
            key={key}
            title={group_data.name}>
              <Button
                onClick={() => act("rename_group", {id: group_data.id})}>
                Rename
              </Button>
              <Button
                onClick={() => act("delete_group", {id: group_data.id})}>
                Delete
              </Button>
              <br />
              {!!group_data.weapons && Object.keys(group_data.weapons).map(key2 => {
                return(
                  <>
                    {key2}<br />
                  </>
                )
              })}
          </Section>
          );
      })}
    </Section>
  )
}
