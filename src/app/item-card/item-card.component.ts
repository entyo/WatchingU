import { Component, Input } from '@angular/core';

import { Item } from '../../models/item';

@Component({
  selector: 'app-item-card',
  templateUrl: './item-card.component.html',
  styleUrls: ['./item-card.component.sass']
})
export class ItemCardComponent {
  @Input() item: Item;

  constructor() {}
}
