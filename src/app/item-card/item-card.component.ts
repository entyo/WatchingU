import { Component, Input } from '@angular/core';

import { Item } from '../shared/models/item';

@Component({
  selector: 'app-item-card',
  templateUrl: './item-card.component.html',
  styleUrls: ['./item-card.component.sass']
})
export class ItemCardComponent {
  @Input() item: Item;

  extractContent(str: string): string {
    const span = document.createElement('span');
    span.innerHTML = str;
    const extracted = span.textContent || span.innerText;
    return this.roundLongString(extracted);
  }

  roundLongString(str: string): string {
    const dadada = str.length > 100 ? '...' : '';
    return str.slice(0, 100) + dadada;
  }

  constructor() {}
}
