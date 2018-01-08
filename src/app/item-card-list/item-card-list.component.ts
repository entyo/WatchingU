import { Component, OnInit } from '@angular/core';

import { Observable } from 'rxjs';
import { TimerObservable } from 'rxjs/observable/TimerObservable';
import { Item } from '../../models/item';
import { ItemStore } from "../shared/stores/item.store";

@Component({
  selector: 'app-item-card-list',
  templateUrl: './item-card-list.component.html',
  styleUrls: ['./item-card-list.component.sass']
})
export class ItemCardListComponent {
  constructor(public store: ItemStore) {
  }
}
