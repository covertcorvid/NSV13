import { Component, forwardRef } from 'inferno';
import { filter, map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../backend';
import { Button, Table, Section, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider, Tooltip, LabeledList } from '../components';
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
                  <Section title="Active Ships:">
                    <LabeledList>
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
