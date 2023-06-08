import { Component, forwardRef } from 'inferno';
import { filter, map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider, Tooltip } from '../components';
import { Window, NtosWindow } from '../layouts';

/**
 * Camera by @robashton returns Camera object.
 * Modified by @Kmc2000 for IE11
 *  constructor initial parameters:
 *  @param {context} str *required
 *  @param {settings} str *optional
  */
//<camera>
const Camera = {
  constructor: function(context, settings) {
      settings = settings || {};
      this.distance = settings.distance || 1000.0;
      this.lookAt = settings.initialPosition || [0, 0];
      this.context = context;
      this.fieldOfView = settings.fieldOfView || Math.PI / 4.0;
      this.viewport = {
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          width: 0,
          height: 0,
          scale: [settings.scaleX || 1.0, settings.scaleY || 1.0]
      };
      this.init();
  },

  /**
   * Camera Initialization
   * -Add listeners.
   * -Initial calculations.
   */
  init: function() {
      this.updateViewport();
  },

  /**
   * Applies to canvas context the parameters:
   *  -Scale
   *  -Translation
   */
  begin: function() {
      this.context.save();
      this.applyScale();
      this.applyTranslation();
  },

  /**
   * 2d Context restore() method
   */
  end: function() {
      this.context.restore();
  },

  /**
   * 2d Context scale(Camera.viewport.scale[0], Camera.viewport.scale[0]) method
   */
  applyScale: function() {
      this.context.scale(this.viewport.scale[0], this.viewport.scale[1]);
  },

  /**
   * 2d Context translate(-Camera.viewport.left, -Camera.viewport.top) method
   */
  applyTranslation: function() {
      this.context.translate(-this.viewport.left, -this.viewport.top);
  },

  /**
   * Camera.viewport data update
   */
  updateViewport: function() {
      this.aspectRatio = this.context.canvas.width / this.context.canvas.height;
      this.viewport.width = this.distance * Math.tan(this.fieldOfView);
      this.viewport.height = this.viewport.width / this.aspectRatio;
      this.viewport.left = this.lookAt[0] - (this.viewport.width / 2.0);
      this.viewport.top = this.lookAt[1] - (this.viewport.height / 2.0);
      this.viewport.right = this.viewport.left + this.viewport.width;
      this.viewport.bottom = this.viewport.top + this.viewport.height;
      this.viewport.scale[0] = this.context.canvas.width / this.viewport.width;
      this.viewport.scale[1] = this.context.canvas.height / this.viewport.height;
  },

  /**
   * Zooms to certain z distance
   * @param {*z distance} z
   */
  zoomTo: function(z) {
      this.distance = z;
      this.updateViewport();
  },

  /**
   * Moves the centre of the viewport to new x, y coords (updates Camera.lookAt)
   * @param {x axis coord} x
   * @param {y axis coord} y
   */
  moveTo: function(x, y) {
      this.lookAt[0] = x;
      this.lookAt[1] = y;
      this.updateViewport();
  },

  /**
   * Transform a coordinate pair from screen coordinates (relative to the canvas) into world coordinates (useful for intersection between mouse and entities)
   * Optional: obj can supply an object to be populated with the x/y (for object-reuse in garbage collection efficient code)
   * @param {x axis coord} x
   * @param {y axis coord} y
   * @param {obj can supply an object to be populated with the x/y} obj
   * @returns
   */
  screenToWorld: function(x, y, obj) {
      obj = obj || {};
      obj.x = (x / this.viewport.scale[0]) + this.viewport.left;
      obj.y = (y / this.viewport.scale[1]) + this.viewport.top;
      return obj;
  },

  /**
   * Transform a coordinate pair from world coordinates into screen coordinates (relative to the canvas) - useful for placing DOM elements over the scene.
   * Optional: obj can supply an object to be populated with the x/y (for object-reuse in garbage collection efficient code).
   * @param {x axis coord} x
   * @param {y axis coord} y
   * @param {obj can supply an object to be populated with the x/y} obj
   * @returns
   */
  worldToScreen: function(x, y, obj) {
      obj = obj || {};
      obj.x = (x - this.viewport.left) * (this.viewport.scale[0]);
      obj.y = (y - this.viewport.top) * (this.viewport.scale[1]);
      return obj;
  }
};//</camera>

/*
 * Original author: nhz-io
 * License: MIT
 * Source (14/05/2023): https://github.com/nhz-io/inferno-canvas-component
 */
class InfernoCanvasComponent extends Component {
  static defaultProps = {
      draw() {}, // eslint-disable-line no-empty-function
      realtime: false,
      top: 0,
      left: 0,
  }

  getChildContext() {
      const {context, props, canvasElement} = this
      const ctx = (context && context.ctx) || (canvasElement && canvasElement.getContext('2d'))
      const realtime = (context && context.realtime) || props.realtime

      return {ctx, realtime}
  }

  constructor(props) {
      super(props)
      this.refDOM = this.refDOM.bind(this)
      this.requestAnimationFrameCallback = this.requestAnimationFrameCallback.bind(this)
  }

  componentDidMount() {
      this.forceUpdate()
      requestAnimationFrame(this.requestAnimationFrameCallback)
  }

  render() {
      const {props, context} = this
      const {draw, realtime, top, left, ...other} = props // eslint-disable-line no-unused-vars
      requestAnimationFrame(this.requestAnimationFrameCallback)

      if (context.ctx) {
          return <div key="canvas" {...other}>{props.children}</div>
      }

      //WARNING: The tabindex bit MIGHT lag it out! but is required to focus the canvas.
      return <canvas tabindex='1' class="bg-space" ref={this.refDOM} key="canvas" {...other}>{props.children}</canvas>
  }

  refDOM(element) {
      this.canvasElement = element
  }

  requestAnimationFrameCallback(time) {
      if (this.previousFrameTime !== time) {
          const {props, context, canvasElement} = this
          const {draw, top, left} = props
          const ctx = (context && context.ctx) || (canvasElement && canvasElement.getContext('2d'))
          const realtime = (context && context.realtime) || props.realtime

          let delta = 0

          if (!draw || !ctx) {
              return
          }


          if (realtime) {
              requestAnimationFrame(this.requestAnimationFrameCallback)

              if (this.previousFrameTime) {
                  delta = time - this.previousFrameTime
              }
              else {
                  this.previousFrameTime = time
              }

              this.previousFrameTime = time
          }

          if (top || left) {
              ctx.translate(left, top)
          }

          draw({time, delta, ctx})

          if (top || left) {
              ctx.translate(-1 * left, -1 * top) // eslint-disable-line no-magic-numbers
          }
      }
  }
}

const canvasWidth = 800;
const canvasHeight = 600;
//Frontend "prediction" constants (old):

/*
//The backend processes at a delay of Xms.
const backend_wait_time = 100; //WAS: 200
//We get a position update every (ROUGHLY) Xms:
const backend_update_interval = 100;//900;
//Which means we wait (usually) 30ms between our updates on screen.
const tick_rate = (backend_update_interval / backend_wait_time) * 10;
const delta_tr = (backend_wait_time / tick_rate);
*/
//The backend runs at this delay.
const backend_tick_rate = 100;
//Which gives us this many FPS if we don't do any interpolation.
const backend_fps = 1000/backend_tick_rate;
//We want to interpolate UP to this framerate. The client MUST be capable of running at least this fast.
const target_fps = 60;//30;
//Which means we have this many ticks per actual game tick
const interpolation_mult = target_fps/backend_fps;
//Giving us a tick rate as such. This is the delay for framerate we have to use.

const tick_rate = backend_tick_rate / interpolation_mult;

class overmapEntity{
  constructor(x,y,z,angle, velocity, velocity_x, velocity_y, icon, thruster_power, rotation_power, sensor_range, armour_quadrants){
    this.x = x;
    this.y = y;
    this.z = z;
    this.angle = angle;
    this.velocity = velocity
    this.velocity_x = velocity_x;
    this.velocity_y = velocity_y;
    this.icon = icon;
    this.thruster_power = thruster_power;
    this.rotation_power = rotation_power;
    this.sensor_range = sensor_range;
    //Pre-calculate radians.
    this.r = (this.angle) * (Math.PI / 180);
    this.armour_quadrants = armour_quadrants;
  }
  //The following procs attempt to model where the ship "ought" to be, based on input.
  process(){
    this.x += (this.velocity_x/interpolation_mult);
    this.y += (this.velocity_y/interpolation_mult);
  }
  rotate(dir){
    //TODO: bodge
    this.angle += this.rotation_power * dir;
    this.r = (this.angle) * (Math.PI / 180);
  }
  thrust(dir){
    // Positive dir is forward, negative dir is backward.
    // Does not permit strafing.
    if(dir == 1){
      this.velocity_x += Math.cos(this.r) * this.thruster_power
      this.velocity_y += Math.sin(this.r) * this.thruster_power
    }
    else{
      this.velocity_x -= Math.cos(this.r) * this.thruster_power
      this.velocity_y -= Math.sin(this.r) * this.thruster_power
      if(this.velocity < 0)
        this.velocity = 0
    }
  }
};


export const JSOvermapGame = (props, context) => {
  const { act, data } = useBackend(context);
  let world = [];
  let active_ship = null;
  const can_pilot = data.can_pilot;

  const rows = 26;
  const cols = 26;

  const gridsize = 2000;
  let previous_frame_time = -1;

  //TODO: maybe try an update flag which triggers a repaint or not?
  if(data != null && data.physics_world.length > 0){
    world = [];
    //world = data.physics_world;
    for(let I = 0; I < data.physics_world.length; I++){
      let ship = data.physics_world[I];
      const sprite = new Image();
      sprite.src = `data:image/jpeg;base64,${ship.icon}`
      world[I] = new overmapEntity(ship.position[0], ship.position[1], ship.position[2], ship.position[3], ship.position[4], ship.position[5], ship.position[6], sprite, ship.thruster_power, ship.rotation_power, ship.sensor_range, ship.armour_quadrants);
      if(ship.active){
        active_ship = world[I];
      }
    }
  let ctx = null;
  function HandleKeyDown(e) {
    act('keydown', {key: e.keyCode});
    let zoomLevel = 0;
    switch(e.keyCode){
      case(68):
        if(!can_pilot)
          return;
        active_ship.rotate(1);
        break;
      case(65):
        if(!can_pilot)
          return;
        active_ship.rotate(-1);
        break;
      case(87):
        if(!can_pilot)
          return;
        active_ship.thrust(1);
        break;
      case(18):
        if(!can_pilot)
          return;
        active_ship.thrust(-1);
        break;
      //Q to zoom out
      case(81):
        zoomLevel = Camera.distance + (1 * 100);
        if (zoomLevel <= 100) {
            zoomLevel = 100;
        }
        Camera.zoomTo(zoomLevel)
        act('scroll', {key: 1});
        break;
      //E to zoom in
      case(69):
        zoomLevel = Camera.distance + (-1 * 100);
        if (zoomLevel <= 100) {
          zoomLevel = 100;
        }
        Camera.zoomTo(zoomLevel)
        act('scroll', {key: -1});
        break;
    }
  }
  /**
   * Get an angle, in degrees, between two points.
   * Degrees are what BYOND likes!
   * @param {*} x1
   * @param {*} y1
   * @param {*} x2
   * @param {*} y2
   * @returns
   */
  function get_angle(x1, y1, x2, y2){
    return Math.atan2(y2 - y1, x2 - x1) * 180 / Math.PI;
  }

  function HandleKeyUp(e) {
    act('keyup', {key: e.keyCode});
  }
  function HandleScroll(e){
    act('scroll', {key: e.deltaY});
  }
  let canvas_rect = null;
  function HandleMouseDown(e){
    if(canvas_rect == null){
      return;
    }
    let xy = Camera.screenToWorld(e.clientX - canvas_rect.left, e.clientY - canvas_rect.top);

    // We get the angle from the center of the icon, not the corner
    act('fire', {
      weapon: -1,
      angle: get_angle(active_ship.x + active_ship.icon.width / 2, active_ship.y + active_ship.icon.height / 2, xy.x, xy.y)
    });
  }

    let last_process_time = 0;

    //Called every tick that the browser can handle.
    function _render({time, delta, ctx}){
        let process = (time - last_process_time >= tick_rate);
        //Initial draw batch.
        if(last_process_time == 0){
          Camera.constructor(ctx);
          Camera.moveTo(active_ship.x, active_ship.y);
          Camera.zoomTo(data.client_zoom);
          canvas_rect = ctx.canvas.getBoundingClientRect();
        }
        //Slave clientside update to ROUGHLY server speed.
        if(!process){
          return;
        }
        last_process_time = time;
        function draw(image, x, y, degrees) {
          let w = image.width;
          let h = image.height;
          degrees = degrees * Math.PI / 180;
          ctx.translate(x + w / 2, y + h / 2);

          ctx.rotate(degrees);

          ctx.drawImage(image, 0, 0, w, h,
              -w / 2, -h / 2, w, h);

          ctx.rotate(-degrees);
          ctx.translate(-x - w / 2, -y - h / 2);
        }

        //TODO: does not work
        function renderFiringArc(image, x, y, angle, start, end, colour="green",radius=300,){
          let w = image.width;
          let h = image.height;
          ctx.strokeStyle = colour;
          ctx.save();
          ctx.translate(x + w / 2, y + h / 2);

          ctx.rotate(angle+start);
          ctx.beginPath();
          ctx.moveTo(0,0);
          ctx.lineTo(-radius,0);
          ctx.rotate(angle+end);
          ctx.beginPath();
          ctx.moveTo(0,0);
          ctx.lineTo(-radius,0);

          ctx.translate(-x - w / 2, -y - h / 2);
          ctx.restore()
          ctx.stroke();


        }
        function radians(d) {
          return d * Math.PI / 180;
      }


      //Mirrored from BYOND side. These constants dictate armour thickness values for rendering.
      const OVERMAP_ARMOUR_THICKNESS_NONE = 0;
      const OVERMAP_ARMOUR_THICKNESS_LIGHT = 250;
      const OVERMAP_ARMOUR_THICKNESS_MEDIUM = 500;
      const OVERMAP_ARMOUR_THICKNESS_HEAVY = 1000;
      const OVERMAP_ARMOUR_THICKNESS_SUPER_HEAVY = 1500;
      const OVERMAP_ARMOUR_THICKNESS_ABLATIVE = 2000;
      const OVERMAP_ARMOUR_THICKNESS_GIGA = 2500;

      function drawArmourQuadrants(image, x, y, radius, offset, segments, size){
        let w = image.width;
        let h = image.height;

        dashedCircle(x + w / 2,y + h / 2,w,offset,segments,size);

      }

        /**
         * ctx - context
         * x / y = center
         * radius = of circle
         * offset = rotation in angle (radians)
         * How many segments circle should be in
         * Size of each segment (of one segment) [0.0, 1.0]
         *
         * CC-Attr: Ken Fyrstenberg
         * Modified by: Kmc2000
        */
        function dashedCircle(x, y, radius, offset, segments, size) {

          var pi2 = 2 * Math.PI,
              segs = pi2 / segments.length,
              len = segs * size,
              i = 0,
              ax, ay;
          let segment_count = 0;
          ctx.save();
          ctx.translate(x, y);
          ctx.rotate(offset);
          ctx.translate(-x, -y);
          for(; i < pi2; i += segs) {
              ctx.beginPath();
              ax = x + radius * Math.cos(i);
              ay = y + radius * Math.sin(i);
              ctx.moveTo(ax, ay);
              let quad = segments[segment_count];
              let max_integrity = quad[1];
              ctx.lineWidth = 1;
              if(max_integrity >= OVERMAP_ARMOUR_THICKNESS_LIGHT){
                ctx.lineWidth = 2.5;
              }
              if(max_integrity >= OVERMAP_ARMOUR_THICKNESS_MEDIUM){
                ctx.lineWidth = 5;
              }
              if(max_integrity >= OVERMAP_ARMOUR_THICKNESS_HEAVY){
                ctx.lineWidth = 10;
              }
              if(max_integrity >= OVERMAP_ARMOUR_THICKNESS_SUPER_HEAVY){
                ctx.lineWidth = 15;
              }
              if(max_integrity >= OVERMAP_ARMOUR_THICKNESS_ABLATIVE){
                ctx.lineWidth = 20;
              }
              if(max_integrity >= OVERMAP_ARMOUR_THICKNESS_GIGA){
                ctx.lineWidth = 40;
              }

              let integrity = quad[0] / max_integrity * 100;

              if(integrity <= 0){
                ctx.strokeStyle = "rgba(0,0,0,0)";
              }
              else if(integrity < 30){
                ctx.strokeStyle = "red";
              }
              if(integrity >= 30){
                ctx.strokeStyle = "orange";
              }
              if(integrity >= 50){
                ctx.strokeStyle = "yellow";
              }
              if(integrity >= 70){
                ctx.strokeStyle = "green";
              }
              segment_count++;
              ctx.arc(x, y, radius, i, i + len);
              ctx.stroke();
          }
          ctx.restore();
        }

        //TODO: set ctx in SetState? Then avoid redraws...
        //TODO: is this thing ACTUALLY re-rendering? I don't think it is!
        function drawCircle(image, x, y, radius){
          ctx.strokeStyle = "green";
          let w = image.width;
          let h = image.height;
          ctx.beginPath();
          //ctx.arc((this.position.x - camera.x()) + w/2, (this.position.y-camera.y())+h/2, radius/scale, 0, 2 * Math.PI);
          ctx.arc((x) + w/2, (y)+h/2, radius, 0, 2 * Math.PI);

          ctx.stroke();
        }
        ctx.clearRect(0, 0, 1280, 720);
        //ctx.fillStyle = "transparent";
        //ctx.fillRect(0, 0, canvas.width, canvas.height);


        if(Camera.distance >= 3000){
          ctx.beginPath();
          //Todo: remove these?
          ctx.fillStyle = "rgba(0,0,0,0.25)";
          ctx.fillRect(0, 0, 1280, 720);
          //todo: world height instead of canvas height...
          for(let i = 0; i < rows; i++){
              for(let j = 0; j < cols; j++){
                  const obj = Camera.worldToScreen(gridsize*i,gridsize*j);
                  ctx.strokeStyle = "rgba(0,255,0,0.2)";
                  ctx.fillStyle = "rgba(0,0,0,0.25)";
                  ctx.moveTo(obj.x, 0);
                  ctx.lineTo(obj.x, 720);
                  ctx.moveTo(0, obj.y);
                  ctx.lineTo(1280, obj.y);
                  ctx.fillStyle = "green";
                  ctx.font = "12pt consolas";
                  ctx.fillText(String.fromCharCode(65+i)+j, obj.x, obj.y);
              }
          }
          ctx.stroke();
      }
      ctx.strokeStyle = "green";
      Camera.begin();
      //TODO: maybe needs map, here?
      //Didn't break when just displaying static sprites.

      for(let I = 0; I < world.length; I++){
        let ship = world[I];
        //TODO: Is visible checks... we can use frustrum culling
        let x = ship.x;
        let y = ship.y;
        if(x <= Camera.viewport.width+Camera.viewport.left && y <= Camera.viewport.height+Camera.viewport.top){
          draw(ship.icon, ship.x, ship.y, ship.angle + 90);

          if(ship.armour_quadrants.length > 0){
            drawArmourQuadrants(ship.icon, ship.x, ship.y, 180, radians(ship.angle + 90), ship.armour_quadrants, 0.8)
          }
          if(ship.sensor_range > 0){
            drawCircle(ship.icon, ship.x, ship.y, ship.sensor_range);
            //TODO: firing arcs! You get one for now :)

            //renderFiringArc(ship.icon, ship.x, ship.y, ship.angle-90, 315, 40);

          }
        }
        ship.process();

      }
      Camera.moveTo(active_ship.x, active_ship.y);
      Camera.end();
      //requestAnimationFrame(_render);
    }
  return (
    <InfernoCanvasComponent
    onKeyDown={(e) => {
      HandleKeyDown(e);
    }}
    onKeyUp={(e) => {
      HandleKeyUp(e);
    }}
    onMouseDown={(e) => {
      HandleMouseDown(e);
    }}
    draw={_render} realtime width={1280} height={720}></InfernoCanvasComponent>
  )}
};
export const JSOvermap = (props, context) => {
  return (
    <Window
      width={1280}
      height={720}
      >
        <Window.Content>
          <JSOvermapGame props={props} context={context}/>
        </Window.Content>
      </Window>
  )}
