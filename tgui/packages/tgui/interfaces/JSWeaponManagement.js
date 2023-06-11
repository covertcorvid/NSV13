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
            label={key}
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
              {}
          </Section>
          );
      })}
    </Section>
  )
}

export const JSOvermap = (props, context) => {
  return (
  <Window
    width={1600}
    height={720}
    >
      <Window.Content>
        <Flex>
          <Flex.Item>
            <JSOvermapGame props={props} context={context}/>
          </Flex.Item>
          <Flex.Item>
            <WeaponManagementPanel props={props} context={context}/>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  )
};
