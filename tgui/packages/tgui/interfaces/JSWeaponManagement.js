import { useBackend } from '../backend';
import { Section, Dropdown, Button, Flex } from '../components';
import { Window } from '../layouts';

export const WeaponManagementPanel = (props, context) => {
  const { data } = useBackend(context);

  return (
    <Section title="Armaments:" buttons={
      <>
        <Button fluid
          onClick={() => {act("add_weapon_group")}}>
          Add Group
        </Button>
        <Button fluid
          onClick={() => {act("default_sort_weapons")}}>
          Reset All
        </Button>
      </>
    }>
      {Object.keys(data.weapon_groups).map(key => {
        let group_data = data.weapon_groups[key];
        return (
          <Section
            key={key}
            title={group_data.name}
            buttons={
              <>
                <Button fluid
                  onClick={() => null} // TODO: Add new weapon panel to the group
                  >
                  Add
                </Button>
                <Button fluid
                  onClick={() => act("rename_group")}>
                  Rename
                </Button>
                <Button fluid
                  onClick={() => act("delete_group")}>
                  Delete
                </Button>
              </>
            }>
              {Object.keys(group_data.weapons).map(key2 => {
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
