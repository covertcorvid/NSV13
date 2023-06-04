import { Component, forwardRef } from 'inferno';
import { filter, map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../backend';
import { Button, Table, Section, NumberInput, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider, Tooltip, LabeledList } from '../components';
import { Window } from '../layouts';
import { JSOvermapGame } from './JSOvermap';

export const JSOvermapPanel = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={1600}
      height={800}
      >
        <Window.Content>
          <Table>
            <Table.Row>
                <Table.Cell>
                  <Section title="Active view:">
                    <JSOvermapGame props={props} context={context}/>
                  </Section>
                </Table.Cell>
                <Table.Cell textAlign="right">
                  <Section title="Options">
                    <LabeledList>
                          <LabeledList.Item label="Control Scheme">
                            <Box mb={1}>
                              <Button
                                icon="eye"
                                content="OBS"
                                color={data.control_scheme == 0 ? "green" : "blue"}
                                onClick={() => act('swap_control_scheme', { target: 0 })}
                              />
                              <Button
                                icon="steering-wheel"
                                content="HLM"
                                color={data.control_scheme == 1 ? "green" : "orange"}
                                onClick={() => act('swap_control_scheme', { target: 1 })}
                              />
                              <Button
                                icon="scanner"
                                content="TAC"
                                color={data.control_scheme == 2 ? "green" : "red"}
                                onClick={() => act('swap_control_scheme', { target: 2 })}
                              />
                              <Button
                                icon="fighter-jet"
                                content="FULL"
                                color={data.control_scheme == 3 ? "green" : "white"}
                                onClick={() => act('swap_control_scheme', { target: 3 })}
                              />
                            </Box>
                          </LabeledList.Item>
                      </LabeledList>
                      <LabeledList>
                          <LabeledList.Item label="Preferences">
                            <Box mb={1}>
                              <Button
                                icon={data.hide_bullets ? "eye-slash" : "eye"}
                                content={data.hide_bullets ? "Show Bullets" : "Hide Bullets"}
                                color={data.hide_bullets? "red" : "green"}
                                onClick={() => act('toggle_hide_bullets', { target: 0 })}
                              />
                            </Box>
                          </LabeledList.Item>
                      </LabeledList>
                      <LabeledList>
                          <LabeledList.Item label="Spawning">
                            <Box mb={1}>
                              <Input
                                value={data.spawn_type}
                                width="250px"
                                onInput={(e, value) => act('set_spawn_type', { target: value
                                })} />
                              <NumberInput
                                value={data.spawn_z}
                                minValue={0}
                                maxValue={9999}
                                stepPixelSize={5}
                                width="39px"
                                onChange={(e, value) => act('set_spawn_z', { target: value
                                })} />
                              <Button
                                icon="plus"
                                content="Spawn"
                                color="green"
                                onClick={() => act('spawn_ship', { target: 1 })}
                              />
                            </Box>
                          </LabeledList.Item>
                      </LabeledList>
                  </Section>
                  <Section title="Active Ships:">
                    <LabeledList scrollable>
                        {Object.keys(data.ships).map(key => {
                        let value = data.ships[key];
                        return (
                          <LabeledList.Item label={value.name} key={key}>
                            <Box mb={1}>
                              <Button
                                color={value.active ? "green" : "blue"}
                                onClick={() => act('track', { target: value.datum })}
                              >
                                <img width={32} height={32} src={`data:image/jpeg;base64,${value.icon}`}/>
                              </Button>
                              <Button
                                icon="search"
                                content="View Vars"
                                color="blue"
                                onClick={() => act('view_vars', { target: value.datum })} />
                            </Box>
                          </LabeledList.Item>
                        );
                      })}
                    </LabeledList>
                  </Section>
                </Table.Cell>
            </Table.Row>
          </Table>


        </Window.Content>
      </Window>
  )}
