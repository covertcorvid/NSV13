/*
* @file
* @copyright 2023 Kmc2000, PowerfulBacon, Vivlas, Covertcorvid
* @license MIT
*/

import { Component, forwardRef } from 'inferno';
import { filter, map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../backend';
import { Section, Flex } from '../components';
import { Window } from '../layouts';
import { JSOvermapGame } from './JSOvermap';
import { WeaponManagementPanel } from './JSWeaponManagement';

export const JSTacticalConsole = (props, context) => {

  return (
    <Window
      width={1600}
      theme="space_80s"
      height={800}>
      <Window.Content>
        <Flex>
          <Flex.Item>
            <Section title="Active view">
              <JSOvermapGame props={props} context={context} />
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section title="Weapon Management">
              <WeaponManagementPanel props={props} context={context}/>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
